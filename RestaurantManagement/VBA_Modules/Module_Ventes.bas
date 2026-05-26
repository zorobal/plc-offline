' ============================================================================
' MODULE: Module Ventes - Gestion des Ventes et Chiffre d'Affaires
' Description: Enregistrement et suivi des ventes journalières
' ============================================================================

Option Explicit

' ============================================================================
' PROCEDURE: EnregistrerVente
' Description: Enregistre une nouvelle vente
' ============================================================================
Public Sub EnregistrerVente()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsVentes As Worksheet
    Set wsVentes = ThisWorkbook.Sheets("Ventes")
    
    ' Trouver la prochaine ligne vide
    Dim nextRow As Long
    nextRow = wsVentes.Cells(wsVentes.Rows.Count, "A").End(xlUp).Row + 1
    
    ' Saisie des données
    Dim idVente As Long
    idVente = nextRow - 1
    
    Dim dateVente As Date
    dateVente = Now
    
    Dim nomPlat As String
    nomPlat = InputBox("Nom du plat/produit vendu:", "Nouvelle Vente")
    If nomPlat = "" Then Exit Sub
    
    Dim categorie As String
    categorie = InputBox("Catégorie (Entrée, Plat, Dessert, Boisson...):", "Nouvelle Vente")
    
    Dim quantite As Double
    quantite = CDbl(InputBox("Quantité vendue:", "Nouvelle Vente"))
    
    If quantite <= 0 Then
        MsgBox "La quantité doit être positive!", vbExclamation, "Erreur"
        Exit Sub
    End If
    
    Dim prixUnitaire As Double
    prixUnitaire = CDbl(InputBox("Prix unitaire:", "Nouvelle Vente"))
    
    Dim modePaiement As String
    modePaiement = InputBox("Mode de paiement (Espèces, CB, Ticket restaurant...):", "Nouvelle Vente")
    
    Dim nomServeur As String
    nomServeur = InputBox("Nom du serveur:", "Nouvelle Vente")
    If nomServeur = "" Then nomServeur = gUserName
    
    ' Calculs
    Dim totalHT As Double
    Dim tvaRate As Double
    Dim totalTTC As Double
    
    tvaRate = 0.10 ' TVA restaurant 10%
    totalHT = quantite * prixUnitaire
    totalTTC = totalHT * (1 + tvaRate)
    
    ' Enregistrement
    wsVentes.Cells(nextRow, 1).Value = idVente
    wsVentes.Cells(nextRow, 2).Value = dateVente
    wsVentes.Cells(nextRow, 3).Value = Format(dateVente, "yyyy-mm-dd")  ' Date pour filtrage
    wsVentes.Cells(nextRow, 4).Value = Format(dateVente, "hh:mm")  ' Heure
    wsVentes.Cells(nextRow, 5).Value = nomPlat
    wsVentes.Cells(nextRow, 6).Value = categorie
    wsVentes.Cells(nextRow, 7).Value = quantite
    wsVentes.Cells(nextRow, 8).Value = prixUnitaire
    wsVentes.Cells(nextRow, 9).Value = totalHT
    wsVentes.Cells(nextRow, 10).Value = tvaRate
    wsVentes.Cells(nextRow, 11).Value = totalTTC
    wsVentes.Cells(nextRow, 12).Value = modePaiement
    wsVentes.Cells(nextRow, 13).Value = nomServeur
    wsVentes.Cells(nextRow, 14).Value = "VALIDEE"  ' Statut
    
    Application.ScreenUpdating = True
    MsgBox "✅ Vente enregistrée!" & vbCrLf & _
           "Total TTC: " & Format(totalTTC, "#,##0.00") & " €", vbInformation, "Vente"
    
    ' Mettre à jour le dashboard si existant
    Call MettreAJourDashboard
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'enregistrement: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: GenererRapportJournalier
' Description: Génère un rapport des ventes de la journée
' ============================================================================
Public Sub GenererRapportJournalier()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsVentes As Worksheet
    Dim wsRapport As Worksheet
    Set wsVentes = ThisWorkbook.Sheets("Ventes")
    
    ' Créer ou réinitialiser la feuille de rapport
    On Error Resume Next
    Set wsRapport = ThisWorkbook.Sheets("Rapport_Journalier")
    If wsRapport Is Nothing Then
        Set wsRapport = ThisWorkbook.Worksheets.Add
        wsRapport.Name = "Rapport_Journalier"
    Else
        wsRapport.Cells.Clear
    End If
    On Error GoTo ErrorHandler
    
    ' Demander la date
    Dim dateRecherche As String
    dateRecherche = InputBox("Date du rapport (JJ/MM/AAAA):", "Rapport Journalier", Format(Date, "dd/mm/yyyy"))
    If dateRecherche = "" Then Exit Sub
    
    ' Filtre des ventes du jour
    Dim lastRow As Long
    lastRow = wsVentes.Cells(wsVentes.Rows.Count, "A").End(xlUp).Row
    
    ' En-têtes du rapport
    wsRapport.Range("A1").Value = "RAPPORT DES VENTES - " & UCase(dateRecherche)
    With wsRapport.Range("A1")
        .Font.Bold = True
        .Font.Size = 16
        .HorizontalAlignment = xlCenter
    End With
    wsRapport.Range("A1:H1").Merge
    
    wsRapport.Range("A3").Value = "Heure"
    wsRapport.Range("B3").Value = "Plat"
    wsRapport.Range("C3").Value = "Catégorie"
    wsRapport.Range("D3").Value = "Qté"
    wsRapport.Range("E3").Value = "P.U."
    wsRapport.Range("F3").Value = "Total HT"
    wsRapport.Range("G3").Value = "Paiement"
    wsRapport.Range("H3").Value = "Serveur"
    
    With wsRapport.Range("A3:H3")
        .Font.Bold = True
        .Interior.Color = RGB(200, 220, 240)
    End With
    
    ' Remplir les données
    Dim reportRow As Long
    reportRow = 4
    
    Dim totalJournee As Double
    totalJournee = 0
    
    Dim i As Long
    For i = 2 To lastRow
        If Format(wsVentes.Cells(i, 3).Value, "dd/mm/yyyy") = dateRecherche Then
            wsRapport.Cells(reportRow, 1).Value = wsVentes.Cells(i, 4).Value
            wsRapport.Cells(reportRow, 2).Value = wsVentes.Cells(i, 5).Value
            wsRapport.Cells(reportRow, 3).Value = wsVentes.Cells(i, 6).Value
            wsRapport.Cells(reportRow, 4).Value = wsVentes.Cells(i, 7).Value
            wsRapport.Cells(reportRow, 5).Value = wsVentes.Cells(i, 8).Value
            wsRapport.Cells(reportRow, 6).Value = wsVentes.Cells(i, 9).Value
            wsRapport.Cells(reportRow, 7).Value = wsVentes.Cells(i, 12).Value
            wsRapport.Cells(reportRow, 8).Value = wsVentes.Cells(i, 13).Value
            
            totalJournee = totalJournee + wsVentes.Cells(i, 9).Value
            reportRow = reportRow + 1
        End If
    Next i
    
    ' Totaux
    wsRapport.Cells(reportRow + 1, 5).Value = "TOTAL JOURNÉE:"
    wsRapport.Cells(reportRow + 1, 5).Font.Bold = True
    wsRapport.Cells(reportRow + 1, 6).Value = totalJournee
    wsRapport.Cells(reportRow + 1, 6).Font.Bold = True
    wsRapport.Cells(reportRow + 1, 6).NumberFormat = "#,##0.00 €"
    
    ' Nombre de ventes
    wsRapport.Cells(reportRow + 2, 5).Value = "Nombre de ventes:"
    wsRapport.Cells(reportRow + 2, 6).Value = reportRow - 4
    
    ' Ajuster les colonnes
    wsRapport.Columns.AutoFit
    
    Application.ScreenUpdating = True
    MsgBox "✅ Rapport généré avec succès!" & vbCrLf & _
           "Chiffre d'affaires: " & Format(totalJournee, "#,##0.00") & " €" & vbCrLf & _
           "Nombre de ventes: " & (reportRow - 4), vbInformation, "Rapport"
    
    wsRapport.Select
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la génération du rapport: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: AnalyserPerformances
' Description: Analyse les performances des produits vendus
' ============================================================================
Public Sub AnalyserPerformances()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsVentes As Worksheet
    Dim wsAnalyse As Worksheet
    Set wsVentes = ThisWorkbook.Sheets("Ventes")
    
    ' Créer ou réinitialiser la feuille d'analyse
    On Error Resume Next
    Set wsAnalyse = ThisWorkbook.Sheets("Analyse_Performances")
    If wsAnalyse Is Nothing Then
        Set wsAnalyse = ThisWorkbook.Worksheets.Add
        wsAnalyse.Name = "Analyse_Performances"
    Else
        wsAnalyse.Cells.Clear
    End If
    On Error GoTo ErrorHandler
    
    ' En-têtes
    wsAnalyse.Range("A1").Value = "ANALYSE DES PERFORMANCES PRODUITS"
    With wsAnalyse.Range("A1")
        .Font.Bold = True
        .Font.Size = 16
    End With
    wsAnalyse.Range("A1:E1").Merge
    
    wsAnalyse.Range("A3").Value = "Produit"
    wsAnalyse.Range("B3").Value = "Catégorie"
    wsAnalyse.Range("C3").Value = "Quantité Vendue"
    wsAnalyse.Range("D3").Value = "Chiffre d'Affaires HT"
    wsAnalyse.Range("E3").Value = "% du CA Total"
    
    With wsAnalyse.Range("A3:E3")
        .Font.Bold = True
        .Interior.Color = RGB(200, 220, 240)
    End With
    
    ' Calculer les performances par produit
    Dim lastRow As Long
    lastRow = wsVentes.Cells(wsVentes.Rows.Count, "A").End(xlUp).Row
    
    ' Dictionnaire pour stocker les totaux par produit
    Dim dictProduits As Object
    Set dictProduits = CreateObject("Scripting.Dictionary")
    
    Dim caTotal As Double
    caTotal = 0
    
    Dim i As Long
    For i = 2 To lastRow
        Dim produit As String
        Dim categorie As String
        Dim quantite As Double
        Dim caLigne As Double
        
        produit = wsVentes.Cells(i, 5).Value
        categorie = wsVentes.Cells(i, 6).Value
        quantite = wsVentes.Cells(i, 7).Value
        caLigne = wsVentes.Cells(i, 9).Value
        
        caTotal = caTotal + caLigne
        
        Dim key As String
        key = produit & "|" & categorie
        
        If Not dictProduits.Exists(key) Then
            dictProduits.Add key, Array(produit, categorie, quantite, caLigne)
        Else
            Dim data As Variant
            data = dictProduits.Item(key)
            data(2) = data(2) + quantite
            data(3) = data(3) + caLigne
            dictProduits.Item(key) = data
        End If
    Next i
    
    ' Remplir le tableau
    Dim row As Long
    row = 4
    
    Dim key As Variant
    For Each key In dictProduits.Keys
        Dim data As Variant
        data = dictProduits.Item(key)
        
        wsAnalyse.Cells(row, 1).Value = data(0)
        wsAnalyse.Cells(row, 2).Value = data(1)
        wsAnalyse.Cells(row, 3).Value = data(2)
        wsAnalyse.Cells(row, 4).Value = data(3)
        wsAnalyse.Cells(row, 5).Value = IIf(caTotal > 0, data(3) / caTotal * 100, 0)
        wsAnalyse.Cells(row, 5).NumberFormat = "0.00%"
        
        row = row + 1
    Next key
    
    ' Trier par CA décroissant
    wsAnalyse.Range("A3:E" & row).Sort Key1:=wsAnalyse.Range("D3"), Order1:=xlDescending, Header:=xlYes
    
    ' Ajuster les colonnes
    wsAnalyse.Columns.AutoFit
    
    Application.ScreenUpdating = True
    MsgBox "✅ Analyse générée avec succès!" & vbCrLf & _
           "CA Total: " & Format(caTotal, "#,##0.00") & " €" & vbCrLf & _
           "Nombre de produits différents: " & dictProduits.Count, vbInformation, "Analyse"
    
    wsAnalyse.Select
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'analyse: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: MettreAJourDashboard
' Description: Met à jour les indicateurs du dashboard
' ============================================================================
Public Sub MettreAJourDashboard()
    On Error GoTo ErrorHandler
    
    Dim wsDashboard As Worksheet
    Set wsDashboard = ThisWorkbook.Sheets("Dashboard")
    
    Dim wsVentes As Worksheet
    Set wsVentes = ThisWorkbook.Sheets("Ventes")
    
    ' Calculer le CA du jour
    Dim today As String
    today = Format(Date, "yyyy-mm-dd")
    
    Dim lastRow As Long
    lastRow = wsVentes.Cells(wsVentes.Rows.Count, "A").End(xlUp).Row
    
    Dim caJour As Double
    Dim nbVentes As Long
    Dim panierMoyen As Double
    
    caJour = 0
    nbVentes = 0
    
    Dim i As Long
    For i = 2 To lastRow
        If wsVentes.Cells(i, 3).Value = today Then
            caJour = caJour + wsVentes.Cells(i, 11).Value  ' Total TTC
            nbVentes = nbVentes + 1
        End If
    Next i
    
    If nbVentes > 0 Then
        panierMoyen = caJour / nbVentes
    Else
        panierMoyen = 0
    End If
    
    ' Mettre à jour le dashboard
    wsDashboard.Range("B3").Value = Format(caJour, "#,##0.00") & " €"
    wsDashboard.Range("B4").Value = nbVentes
    wsDashboard.Range("B5").Value = Format(panierMoyen, "#,##0.00") & " €"
    wsDashboard.Range("B6").Value = Format(Date, "dd/mm/yyyy") & " " & Format(Time, "hh:mm")
    
    Exit Sub
    
ErrorHandler:
    ' Ignorer les erreurs silencieusement pour ne pas bloquer l'enregistrement des ventes
End Sub
