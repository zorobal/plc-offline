' ============================================================================
' MODULE: Module Stocks - Gestion des Stocks et Matières Premières
' Description: Gestion complète des stocks, entrées/sorties, alertes
' ============================================================================

Option Explicit

' ============================================================================
' PROCEDURE: AjouterProduit
' Description: Ajoute un nouveau produit au stock
' ============================================================================
Public Sub AjouterProduit()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Stocks")
    
    ' Trouver la prochaine ligne vide
    Dim nextRow As Long
    nextRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row + 1
    
    ' Saisie des données via InputBox
    Dim refProduct As String
    Dim nomProduct As String
    Dim categorie As String
    Dim uniteMesure As String
    Dim prixAchat As Double
    Dim prixVente As Double
    Dim stockMin As Double
    Dim stockSecurite As Double
    
    refProduct = InputBox("Référence du produit:", "Ajout Produit")
    If refProduct = "" Then Exit Sub
    
    nomProduct = InputBox("Nom du produit:", "Ajout Produit")
    If nomProduct = "" Then Exit Sub
    
    categorie = InputBox("Catégorie:", "Ajout Produit")
    uniteMesure = InputBox("Unité de mesure (kg, L, unité...):", "Ajout Produit")
    
    prixAchat = CDbl(InputBox("Prix d'achat unitaire:", "Ajout Produit"))
    prixVente = CDbl(InputBox("Prix de vente unitaire:", "Ajout Produit"))
    
    stockMin = CDbl(InputBox("Stock minimum:", "Ajout Produit"))
    stockSecurite = CDbl(InputBox("Stock de sécurité:", "Ajout Produit"))
    
    ' Insérer les données
    ws.Cells(nextRow, 1).Value = nextRow - 1  ' ID
    ws.Cells(nextRow, 2).Value = refProduct
    ws.Cells(nextRow, 3).Value = nomProduct
    ws.Cells(nextRow, 4).Value = categorie
    ws.Cells(nextRow, 5).Value = uniteMesure
    ws.Cells(nextRow, 6).Value = prixAchat
    ws.Cells(nextRow, 7).Value = prixVente
    ws.Cells(nextRow, 8).Value = 0  ' Stock actuel (initialisé à 0)
    ws.Cells(nextRow, 9).Value = stockMin
    ws.Cells(nextRow, 10).Value = stockSecurite
    ws.Cells(nextRow, 11).Value = Now  ' Date de mise à jour
    
    Application.ScreenUpdating = True
    MsgBox "✅ Produit ajouté avec succès!", vbInformation, "Ajout"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'ajout: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: ModifierProduit
' Description: Modifie un produit existant
' ============================================================================
Public Sub ModifierProduit()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Stocks")
    
    Dim productId As Variant
    productId = InputBox("Entrez l'ID du produit à modifier:", "Modification")
    
    If productId = "" Or Not IsNumeric(productId) Then Exit Sub
    
    ' Trouver le produit
    Dim foundRow As Long
    foundRow = 0
    
    Dim i As Long
    For i = 2 To ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
        If ws.Cells(i, 1).Value = productId Then
            foundRow = i
            Exit For
        End If
    Next i
    
    If foundRow = 0 Then
        MsgBox "Produit non trouvé!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Modifier les informations
    Dim nouveauNom As String
    nouveauNom = InputBox("Nouveau nom (actuel: " & ws.Cells(foundRow, 3).Value & "):", _
                          "Modification")
    If nouveauNom <> "" Then ws.Cells(foundRow, 3).Value = nouveauNom
    
    Dim nouveauPrixAchat As String
    nouveauPrixAchat = InputBox("Nouveau prix d'achat (actuel: " & ws.Cells(foundRow, 6).Value & "):", _
                                 "Modification")
    If nouveauPrixAchat <> "" Then ws.Cells(foundRow, 6).Value = CDbl(nouveauPrixAchat)
    
    Dim nouveauPrixVente As String
    nouveauPrixVente = InputBox("Nouveau prix de vente (actuel: " & ws.Cells(foundRow, 7).Value & "):", _
                                 "Modification")
    If nouveauPrixVente <> "" Then ws.Cells(foundRow, 7).Value = CDbl(nouveauPrixVente)
    
    ' Mettre à jour la date
    ws.Cells(foundRow, 11).Value = Now
    
    Application.ScreenUpdating = True
    MsgBox "✅ Produit modifié avec succès!", vbInformation, "Modification"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la modification: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: EnregistrerEntreeStock
' Description: Enregistre une entrée de stock
' ============================================================================
Public Sub EnregistrerEntreeStock()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsStock As Worksheet
    Dim wsMouvements As Worksheet
    Set wsStock = ThisWorkbook.Sheets("Stocks")
    Set wsMouvements = ThisWorkbook.Sheets("Mouvements_Stock")
    
    ' Sélection du produit
    Dim productId As Variant
    productId = InputBox("Entrez l'ID du produit:", "Entrée de Stock")
    
    If productId = "" Or Not IsNumeric(productId) Then Exit Sub
    
    ' Trouver le produit
    Dim foundRow As Long
    foundRow = 0
    
    Dim i As Long
    For i = 2 To wsStock.Cells(wsStock.Rows.Count, "A").End(xlUp).Row
        If wsStock.Cells(i, 1).Value = productId Then
            foundRow = i
            Exit For
        End If
    Next i
    
    If foundRow = 0 Then
        MsgBox "Produit non trouvé!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Quantité reçue
    Dim quantite As Double
    quantite = CDbl(InputBox("Quantité reçue:", "Entrée de Stock"))
    
    If quantite <= 0 Then
        MsgBox "La quantité doit être positive!", vbExclamation, "Erreur"
        Exit Sub
    End If
    
    ' Numéro de bon de commande/facture
    Dim numDocument As String
    numDocument = InputBox("Numéro de document (bon de commande/facture):", "Entrée de Stock")
    
    ' Mettre à jour le stock
    wsStock.Cells(foundRow, 8).Value = wsStock.Cells(foundRow, 8).Value + quantite
    wsStock.Cells(foundRow, 11).Value = Now
    
    ' Enregistrer le mouvement
    Dim nextRow As Long
    nextRow = wsMouvements.Cells(wsMouvements.Rows.Count, "A").End(xlUp).Row + 1
    
    wsMouvements.Cells(nextRow, 1).Value = nextRow - 1  ' ID
    wsMouvements.Cells(nextRow, 2).Value = Now  ' Date
    wsMouvements.Cells(nextRow, 3).Value = productId  ' ID Produit
    wsMouvements.Cells(nextRow, 4).Value = wsStock.Cells(foundRow, 3).Value  ' Nom Produit
    wsMouvements.Cells(nextRow, 5).Value = "ENTREE"  ' Type
    wsMouvements.Cells(nextRow, 6).Value = quantite  ' Quantité
    wsMouvements.Cells(nextRow, 7).Value = wsStock.Cells(foundRow, 6).Value  ' Prix unitaire
    wsMouvements.Cells(nextRow, 8).Value = quantite * wsStock.Cells(foundRow, 6).Value  ' Total
    wsMouvements.Cells(nextRow, 9).Value = numDocument  ' Document
    wsMouvements.Cells(nextRow, 10).Value = gUserName  ' Utilisateur
    
    Application.ScreenUpdating = True
    MsgBox "✅ Entrée de stock enregistrée!" & vbCrLf & _
           "Nouveau stock: " & wsStock.Cells(foundRow, 8).Value & " " & _
           wsStock.Cells(foundRow, 5).Value, vbInformation, "Entrée"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'entrée de stock: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: EnregistrerSortieStock
' Description: Enregistre une sortie de stock
' ============================================================================
Public Sub EnregistrerSortieStock()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsStock As Worksheet
    Dim wsMouvements As Worksheet
    Set wsStock = ThisWorkbook.Sheets("Stocks")
    Set wsMouvements = ThisWorkbook.Sheets("Mouvements_Stock")
    
    ' Sélection du produit
    Dim productId As Variant
    productId = InputBox("Entrez l'ID du produit:", "Sortie de Stock")
    
    If productId = "" Or Not IsNumeric(productId) Then Exit Sub
    
    ' Trouver le produit
    Dim foundRow As Long
    foundRow = 0
    
    Dim i As Long
    For i = 2 To wsStock.Cells(wsStock.Rows.Count, "A").End(xlUp).Row
        If wsStock.Cells(i, 1).Value = productId Then
            foundRow = i
            Exit For
        End If
    Next i
    
    If foundRow = 0 Then
        MsgBox "Produit non trouvé!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Quantité sortie
    Dim quantite As Double
    quantite = CDbl(InputBox("Quantité sortie:", "Sortie de Stock"))
    
    If quantite <= 0 Then
        MsgBox "La quantité doit être positive!", vbExclamation, "Erreur"
        Exit Sub
    End If
    
    ' Vérifier le stock disponible
    If quantite > wsStock.Cells(foundRow, 8).Value Then
        MsgBox "⚠️ Stock insuffisant!" & vbCrLf & _
               "Stock actuel: " & wsStock.Cells(foundRow, 8).Value & " " & _
               wsStock.Cells(foundRow, 5).Value, vbExclamation, "Alerte"
        
        Dim continuer As VbMsgBoxResult
        continuer = MsgBox("Voulez-vous quand même enregistrer cette sortie?", _
                          vbYesNo + vbQuestion, "Confirmation")
        If continuer = vbNo Then Exit Sub
    End If
    
    ' Raison de la sortie
    Dim raison As String
    raison = InputBox("Raison de la sortie (vente, perte, gaspillage...):", "Sortie de Stock")
    
    ' Mettre à jour le stock
    wsStock.Cells(foundRow, 8).Value = wsStock.Cells(foundRow, 8).Value - quantite
    wsStock.Cells(foundRow, 11).Value = Now
    
    ' Enregistrer le mouvement
    Dim nextRow As Long
    nextRow = wsMouvements.Cells(wsMouvements.Rows.Count, "A").End(xlUp).Row + 1
    
    wsMouvements.Cells(nextRow, 1).Value = nextRow - 1  ' ID
    wsMouvements.Cells(nextRow, 2).Value = Now  ' Date
    wsMouvements.Cells(nextRow, 3).Value = productId  ' ID Produit
    wsMouvements.Cells(nextRow, 4).Value = wsStock.Cells(foundRow, 3).Value  ' Nom Produit
    wsMouvements.Cells(nextRow, 5).Value = "SORTIE"  ' Type
    wsMouvements.Cells(nextRow, 6).Value = quantite  ' Quantité
    wsMouvements.Cells(nextRow, 7).Value = wsStock.Cells(foundRow, 6).Value  ' Prix unitaire
    wsMouvements.Cells(nextRow, 8).Value = quantite * wsStock.Cells(foundRow, 6).Value  ' Total
    wsMouvements.Cells(nextRow, 9).Value = raison  ' Raison
    wsMouvements.Cells(nextRow, 10).Value = gUserName  ' Utilisateur
    
    Application.ScreenUpdating = True
    MsgBox "✅ Sortie de stock enregistrée!" & vbCrLf & _
           "Nouveau stock: " & wsStock.Cells(foundRow, 8).Value & " " & _
           wsStock.Cells(foundRow, 5).Value, vbInformation, "Sortie"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la sortie de stock: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: GenererAlertesStock
' Description: Génère un rapport des alertes de stock
' ============================================================================
Public Sub GenererAlertesStock()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsStock As Worksheet
    Dim wsAlertes As Worksheet
    Set wsStock = ThisWorkbook.Sheets("Stocks")
    
    ' Créer ou réinitialiser la feuille d'alertes
    On Error Resume Next
    Set wsAlertes = ThisWorkbook.Sheets("Alertes_Stock")
    If wsAlertes Is Nothing Then
        Set wsAlertes = ThisWorkbook.Worksheets.Add
        wsAlertes.Name = "Alertes_Stock"
    Else
        wsAlertes.Cells.Clear
    End If
    On Error GoTo ErrorHandler
    
    ' En-têtes
    wsAlertes.Range("A1").Value = "ID"
    wsAlertes.Range("B1").Value = "Référence"
    wsAlertes.Range("C1").Value = "Produit"
    wsAlertes.Range("D1").Value = "Stock Actuel"
    wsAlertes.Range("E1").Value = "Stock Minimum"
    wsAlertes.Range("F1").Value = "Stock Sécurité"
    wsAlertes.Range("G1").Value = "Type Alerte"
    wsAlertes.Range("H1").Value = "Date"
    
    ' Formatage
    With wsAlertes.Range("A1:H1")
        .Font.Bold = True
        .Interior.Color = RGB(255, 200, 200)
    End With
    
    Dim alertRow As Long
    alertRow = 2
    
    Dim i As Long
    For i = 2 To wsStock.Cells(wsStock.Rows.Count, "A").End(xlUp).Row
        Dim stockActuel As Double
        Dim stockMin As Double
        Dim stockSecurite As Double
        
        stockActuel = wsStock.Cells(i, 8).Value
        stockMin = wsStock.Cells(i, 9).Value
        stockSecurite = wsStock.Cells(i, 10).Value
        
        ' Vérifier rupture de stock
        If stockActuel = 0 Then
            wsAlertes.Cells(alertRow, 1).Value = wsStock.Cells(i, 1).Value
            wsAlertes.Cells(alertRow, 2).Value = wsStock.Cells(i, 2).Value
            wsAlertes.Cells(alertRow, 3).Value = wsStock.Cells(i, 3).Value
            wsAlertes.Cells(alertRow, 4).Value = stockActuel
            wsAlertes.Cells(alertRow, 5).Value = stockMin
            wsAlertes.Cells(alertRow, 6).Value = stockSecurite
            wsAlertes.Cells(alertRow, 7).Value = "RUPTURE TOTALE"
            wsAlertes.Cells(alertRow, 8).Value = Now
            wsAlertes.Rows(alertRow).Interior.Color = RGB(255, 0, 0)
            alertRow = alertRow + 1
        ' Vérifier stock critique
        ElseIf stockActuel <= stockSecurite Then
            wsAlertes.Cells(alertRow, 1).Value = wsStock.Cells(i, 1).Value
            wsAlertes.Cells(alertRow, 2).Value = wsStock.Cells(i, 2).Value
            wsAlertes.Cells(alertRow, 3).Value = wsStock.Cells(i, 3).Value
            wsAlertes.Cells(alertRow, 4).Value = stockActuel
            wsAlertes.Cells(alertRow, 5).Value = stockMin
            wsAlertes.Cells(alertRow, 6).Value = stockSecurite
            wsAlertes.Cells(alertRow, 7).Value = "STOCK CRITIQUE"
            wsAlertes.Cells(alertRow, 8).Value = Now
            wsAlertes.Rows(alertRow).Interior.Color = RGB(255, 165, 0)
            alertRow = alertRow + 1
        ' Vérifier stock minimum
        ElseIf stockActuel <= stockMin Then
            wsAlertes.Cells(alertRow, 1).Value = wsStock.Cells(i, 1).Value
            wsAlertes.Cells(alertRow, 2).Value = wsStock.Cells(i, 2).Value
            wsAlertes.Cells(alertRow, 3).Value = wsStock.Cells(i, 3).Value
            wsAlertes.Cells(alertRow, 4).Value = stockActuel
            wsAlertes.Cells(alertRow, 5).Value = stockMin
            wsAlertes.Cells(alertRow, 6).Value = stockSecurite
            wsAlertes.Cells(alertRow, 7).Value = "STOCK MINIMUM ATTEINT"
            wsAlertes.Cells(alertRow, 8).Value = Now
            wsAlertes.Rows(alertRow).Interior.Color = RGB(255, 255, 0)
            alertRow = alertRow + 1
        End If
    Next i
    
    ' Ajuster les colonnes
    wsAlertes.Columns.AutoFit
    
    Application.ScreenUpdating = True
    
    If alertRow > 2 Then
        MsgBox "⚠️ " & (alertRow - 2) & " alerte(s) de stock détectée(s)!" & vbCrLf & _
               "Consultez la feuille 'Alertes_Stock'", vbExclamation, "Alertes"
        wsAlertes.Select
    Else
        MsgBox "✅ Aucun problème de stock détecté", vbInformation, "Statut"
    End If
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la génération des alertes: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: CalculerValeurStock
' Description: Calcule la valeur totale du stock
' ============================================================================
Public Function CalculerValeurStock() As Double
    On Error GoTo ErrorHandler
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Stocks")
    
    Dim totalValue As Double
    totalValue = 0
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Dim i As Long
    For i = 2 To lastRow
        Dim stockActuel As Double
        Dim prixAchat As Double
        
        stockActuel = ws.Cells(i, 8).Value
        prixAchat = ws.Cells(i, 6).Value
        
        totalValue = totalValue + (stockActuel * prixAchat)
    Next i
    
    CalculerValeurStock = totalValue
    Exit Function
    
ErrorHandler:
    CalculerValeurStock = 0
End Function
