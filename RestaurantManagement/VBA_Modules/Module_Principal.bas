' ============================================================================
' MODULE: Module Principal - Gestion Restaurant
' Description: Module principal contenant les fonctions de navigation et utilitaires
' ============================================================================

Option Explicit

' Déclaration des variables globales
Public gUserName As String
Public gLoginTime As Date
Public gLastBackup As Date

' ============================================================================
' PROCEDURE: InitialiserApplication
' Description: Initialise l'application au démarrage
' ============================================================================
Public Sub InitialiserApplication()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationAutomatic
    Application.EnableEvents = True
    
    ' Vérifier si c'est la première utilisation
    If ThisWorkbook.Sheets("Config").Range("B1").Value = "" Then
        Call ConfigurerPremiereUtilisation
    End If
    
    ' Charger le nom d'utilisateur
    gUserName = Environ("USERNAME")
    If gUserName = "" Then gUserName = "Utilisateur"
    
    gLoginTime = Now
    
    ' Afficher la page d'accueil
    Call AfficherPageAccueil
    
    Application.ScreenUpdating = True
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur lors de l'initialisation: " & Err.Description, vbCritical, "Erreur"
    Application.ScreenUpdating = True
End Sub

' ============================================================================
' PROCEDURE: AfficherPageAccueil
' Description: Affiche la feuille d'accueil
' ============================================================================
Public Sub AfficherPageAccueil()
    On Error GoTo ErrorHandler
    
    Dim ws As Worksheet
    
    For Each ws In ThisWorkbook.Worksheets
        ws.Visible = xlSheetVisible
    Next ws
    
    Sheets("Accueil").Select
    Sheets("Accueil").Activate
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: NaviguerVersModule
' Description: Navigation vers un module spécifique
' Paramètres: moduleName - Nom du module à afficher
' ============================================================================
Public Sub NaviguerVersModule(moduleName As String)
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim ws As Worksheet
    Dim found As Boolean
    found = False
    
    For Each ws In ThisWorkbook.Worksheets
        If ws.Name Like "*" & moduleName & "*" Then
            ws.Visible = xlSheetVisible
            ws.Select
            ws.Activate
            found = True
            Exit For
        End If
    Next ws
    
    If Not found Then
        MsgBox "Module non trouvé: " & moduleName, vbExclamation, "Attention"
    End If
    
    Application.ScreenUpdating = True
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur de navigation: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: VerifierAlertes
' Description: Vérifie et affiche les alertes importantes
' ============================================================================
Public Sub VerifierAlertes()
    On Error GoTo ErrorHandler
    
    Dim alertes As String
    Dim count As Integer
    count = 0
    
    ' Vérifier les ruptures de stock
    Dim wsStock As Worksheet
    Set wsStock = ThisWorkbook.Sheets("Stocks")
    
    Dim lastRow As Long
    lastRow = wsStock.Cells(wsStock.Rows.Count, "A").End(xlUp).Row
    
    Dim i As Long
    For i = 2 To lastRow
        If wsStock.Cells(i, 5).Value <= wsStock.Cells(i, 7).Value Then
            alertes = alertes & "- Rupture de stock: " & wsStock.Cells(i, 2).Value & vbCrLf
            count = count + 1
        End If
    Next i
    
    ' Afficher les alertes
    If count > 0 Then
        MsgBox "⚠️ " & count & " alerte(s) détectée(s):" & vbCrLf & vbCrLf & alertes, _
               vbExclamation, "Alertes Importantes"
    Else
        MsgBox "✅ Aucune alerte détectée", vbInformation, "Statut"
    End If
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur lors de la vérification des alertes: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: SauvegarderDonnees
' Description: Crée une sauvegarde des données
' ============================================================================
Public Sub SauvegarderDonnees()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim backupPath As String
    Dim backupName As String
    Dim timestamp As String
    
    timestamp = Format(Now, "yyyymmdd_hhnnss")
    backupName = "Backup_Restaurant_" & timestamp & ".xlsm"
    
    ' Créer un dossier de sauvegarde s'il n'existe pas
    backupPath = ThisWorkbook.Path & "\Backups\"
    If Dir(backupPath, vbDirectory) = "" Then
        MkDir backupPath
    End If
    
    ' Copier le fichier
    ThisWorkbook.SaveCopyAs backupPath & backupName
    
    gLastBackup = Now
    
    ' Mettre à jour la feuille de config
    ThisWorkbook.Sheets("Config").Range("B3").Value = gLastBackup
    
    Application.ScreenUpdating = True
    MsgBox "✅ Sauvegarde créée avec succès:" & vbCrLf & backupPath & backupName, _
           vbInformation, "Sauvegarde"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la sauvegarde: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: ConfigurerPremiereUtilisation
' Description: Configure l'application pour la première utilisation
' ============================================================================
Private Sub ConfigurerPremiereUtilisation()
    On Error GoTo ErrorHandler
    
    Dim wsConfig As Worksheet
    Set wsConfig = ThisWorkbook.Sheets("Config")
    
    ' Configuration initiale
    wsConfig.Range("A1").Value = "Date de création"
    wsConfig.Range("B1").Value = Now
    wsConfig.Range("A2").Value = "Version"
    wsConfig.Range("B2").Value = "1.0.0"
    wsConfig.Range("A3").Value = "Dernière sauvegarde"
    
    MsgBox "✅ Application configurée avec succès!", vbInformation, "Configuration"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Erreur de configuration: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: ActualiserTableauxCroises
' Description: Actualise tous les tableaux croisés dynamiques
' ============================================================================
Public Sub ActualiserTableauxCroises()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim ws As Worksheet
    Dim pt As PivotTable
    
    For Each ws In ThisWorkbook.Worksheets
        For Each pt In ws.PivotTables
            pt.RefreshTable
        Next pt
    Next ws
    
    Application.ScreenUpdating = True
    MsgBox "✅ Tous les tableaux croisés ont été actualisés", vbInformation, "Actualisation"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'actualisation: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: ExporterRapport
' Description: Exporte un rapport au format PDF
' Paramètres: sheetName - Nom de la feuille à exporter
' ============================================================================
Public Sub ExporterRapport(sheetName As String)
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(sheetName)
    
    Dim exportPath As String
    Dim fileName As String
    
    fileName = "Rapport_" & sheetName & "_" & Format(Date, "yyyymmdd") & ".pdf"
    exportPath = ThisWorkbook.Path & "\Reports\" & fileName
    
    ' Créer le dossier Reports s'il n'existe pas
    If Dir(ThisWorkbook.Path & "\Reports\", vbDirectory) = "" Then
        MkDir ThisWorkbook.Path & "\Reports"
    End If
    
    ws.ExportAsFixedFormat Type:=xlTypePDF, fileName:=exportPath
    
    Application.ScreenUpdating = True
    MsgBox "✅ Rapport exporté: " & exportPath, vbInformation, "Export"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'export: " & Err.Description, vbCritical, "Erreur"
End Sub
