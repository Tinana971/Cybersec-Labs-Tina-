<#
 Audit-Win11-CIS.ps1
 Audit en LECTURE SEULE de quelques controles du
 "CIS Microsoft Windows 11 Enterprise Benchmark v5.1.1".
 A lancer dans PowerShell ouvert en administrateur.
 Sortie : tableau a l'ecran + rapport_audit_CIS.csv (dossier courant).
 Note : le fichier est volontairement sans accents (compatibilite PowerShell 5.1).
#>

#Requires -RunAsAdministrator

$resultats = New-Object System.Collections.Generic.List[object]

# --- Export de la politique de securite locale (independant de la langue) ---
$cfg = Join-Path $env:TEMP "audit_secpol.inf"
secedit /export /cfg $cfg /areas SECURITYPOLICY | Out-Null
$sec = @{}
Get-Content $cfg -Encoding Unicode | ForEach-Object {
    if ($_ -match '^\s*(\w+)\s*=\s*(.+?)\s*$') { $sec[$Matches[1]] = $Matches[2] }
}
Remove-Item $cfg -ErrorAction SilentlyContinue

# Lit une valeur de la politique de securite (renvoie rien si elle est absente)
function Get-Sec([string]$Cle) {
    if ($sec.ContainsKey($Cle)) { [int]$sec[$Cle] }
}

# Evalue un controle : $Valeur lit la valeur, $Regle dit si elle est conforme
function Test-Controle {
    param(
        [string]$Ref, [string]$Controle, [string]$Attendu,
        [scriptblock]$Valeur, [scriptblock]$Regle
    )
    try {
        $obtenu = & $Valeur
        if ($null -eq $obtenu -or "$obtenu" -eq "") { $obtenu = "(vide)"; $statut = "NON_EVALUE" }
        elseif (& $Regle $obtenu) { $statut = "CONFORME" }
        else { $statut = "ECART" }
    }
    catch { $obtenu = "erreur"; $statut = "NON_EVALUE" }
    $resultats.Add([pscustomobject]@{
        Ref_CIS = $Ref; Controle = $Controle; Attendu = $Attendu
        Obtenu = "$obtenu"; Statut = $statut
    })
}

# --- 1.1 Politique de mot de passe ---
Test-Controle '1.1.1' 'Historique des mots de passe' '24 ou plus' { Get-Sec 'PasswordHistorySize' } { param($v) $v -ge 24 }
Test-Controle '1.1.2' 'Duree de vie maximale (jours)' '1 a 365' { Get-Sec 'MaximumPasswordAge' } { param($v) $v -ge 1 -and $v -le 365 }
Test-Controle '1.1.3' 'Duree de vie minimale (jours)' '1 ou plus' { Get-Sec 'MinimumPasswordAge' } { param($v) $v -ge 1 }
Test-Controle '1.1.4' 'Longueur minimale' '14 ou plus' { Get-Sec 'MinimumPasswordLength' } { param($v) $v -ge 14 }
Test-Controle '1.1.5' 'Complexite du mot de passe' '1 (active)' { Get-Sec 'PasswordComplexity' } { param($v) $v -eq 1 }
Test-Controle '1.1.7' 'Chiffrement reversible' '0 (desactive)' { Get-Sec 'ClearTextPassword' } { param($v) $v -eq 0 }

# --- 1.2 Verrouillage de compte ---
Test-Controle '1.2.1' 'Duree de verrouillage (min)' '15 ou plus' { Get-Sec 'LockoutDuration' } { param($v) $v -ge 15 }
Test-Controle '1.2.2' 'Seuil de verrouillage' '1 a 5' { Get-Sec 'LockoutBadCount' } { param($v) $v -ge 1 -and $v -le 5 }
Test-Controle '1.2.4' 'Reinitialisation du compteur (min)' '15 ou plus' { Get-Sec 'ResetLockoutCount' } { param($v) $v -ge 15 }

# --- 2.3.1.1 Compte Invite (reconnu par son SID, quelle que soit la langue) ---
Test-Controle '2.3.1.1' 'Compte Invite desactive' 'Enabled = False' {
    (Get-LocalUser | Where-Object { $_.SID.Value -like '*-501' }).Enabled
} { param($v) $v -eq $false }

# --- 2.3.10.x Enumeration anonyme ---
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Test-Controle '2.3.10.2' 'Enumeration anonyme des comptes SAM' 'RestrictAnonymousSAM = 1' {
    (Get-ItemProperty -Path $lsa -Name RestrictAnonymousSAM).RestrictAnonymousSAM
} { param($v) $v -eq 1 }
Test-Controle '2.3.10.3' 'Enumeration anonyme des comptes et partages SAM' 'RestrictAnonymous = 1' {
    (Get-ItemProperty -Path $lsa -Name RestrictAnonymous).RestrictAnonymous
} { param($v) $v -eq 1 }

# --- 9.x Pare-feu Windows (etat des 3 profils) ---
foreach ($p in @(@('9.1.1', 'Domain'), @('9.2.1', 'Private'), @('9.3.1', 'Public'))) {
    $profil = $p[1]
    Test-Controle $p[0] "Pare-feu actif (profil $profil)" 'True' {
        (Get-NetFirewallProfile -Name $profil).Enabled
    } { param($v) "$v" -eq 'True' }
}

# --- SMBv1 (lien indirect avec 18.4.2 / 18.4.3 : ici on lit l'etat de la fonctionnalite) ---
Test-Controle '18.4.3 (indirect)' 'Fonctionnalite SMBv1 desactivee' 'Disabled' {
    (Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State
} { param($v) "$v" -like 'Disabled*' }

# --- Rapport ---
$os = Get-CimInstance Win32_OperatingSystem
Write-Host ("Systeme : {0} - version {1}" -f $os.Caption, $os.Version)
Write-Host ("Date    : {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm'))
$resultats | Format-Table Ref_CIS, Statut, Obtenu, Controle -AutoSize -Wrap

$ok = @($resultats | Where-Object Statut -eq 'CONFORME').Count
$ecarts = @($resultats | Where-Object Statut -eq 'ECART').Count
$nonEval = @($resultats | Where-Object Statut -eq 'NON_EVALUE').Count
Write-Host "Conformes : $ok / $($resultats.Count) | Ecarts : $ecarts | Non evalues : $nonEval"

$sortie = Join-Path (Get-Location) 'rapport_audit_CIS.csv'
$resultats | Export-Csv $sortie -NoTypeInformation -Encoding UTF8 -Delimiter ';'
Write-Host "Rapport enregistre : $sortie"

