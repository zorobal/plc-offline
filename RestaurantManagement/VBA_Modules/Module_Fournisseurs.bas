' ============================================================================
' MODULE: Module Fournisseurs - Gestion des Fournisseurs et Achats
' Description: Gestion complète des fournisseurs, commandes et achats
' ============================================================================

Option Explicit

' ============================================================================
' PROCEDURE: AjouterFournisseur
' Description: Ajoute un nouveau fournisseur
' ============================================================================
Public Sub AjouterFournisseur()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Fournisseurs")
    
    ' Trouver la prochaine ligne vide
    Dim nextRow As Long
    nextRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row + 1
    
    ' Saisie des données
    Dim nomFournisseur As String
    nomFournisseur = InputBox("Nom du fournisseur:", "Nouveau Fournisseur")
    If nomFournisseur = "" Then Exit Sub
    
    Dim contact As String
    contact = InputBox("Nom du contact:", "Nouveau Fournisseur")
    
    Dim telephone As String
    telephone = InputBox("Numéro de téléphone:", "Nouveau Fournisseur")
    
    Dim email As String
    email = InputBox("Adresse email:", "Nouveau Fournisseur")
    
    Dim adresse As String
    adresse = InputBox("Adresse postale:", "Nouveau Fournisseur")
    
    Dim categorie As String
    categorie = InputBox("Catégorie (Viandes, Légumes, Boissons...):", "Nouveau Fournisseur")
    
    ' Enregistrement
    ws.Cells(nextRow, 1).Value = nextRow - 1  ' ID
    ws.Cells(nextRow, 2).Value = nomFournisseur
    ws.Cells(nextRow, 3).Value = contact
    ws.Cells(nextRow, 4).Value = telephone
    ws.Cells(nextRow, 5).Value = email
    ws.Cells(nextRow, 6).Value = adresse
    ws.Cells(nextRow, 7).Value = categorie
    ws.Cells(nextRow, 8).Value = "ACTIF"  ' Statut
    ws.Cells(nextRow, 9).Value = Now  ' Date création
    ws.Cells(nextRow, 10).Value = 0  ' Nombre de commandes
    ws.Cells(nextRow, 11).Value = 0  ' Montant total acheté
    
    Application.ScreenUpdating = True
    MsgBox "✅ Fournisseur '" & nomFournisseur & "' ajouté avec succès!" & vbCrLf & _
           "ID Fournisseur: " & (nextRow - 1), vbInformation, "Fournisseur ajouté"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'ajout: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: PasserCommande
' Description: Enregistre une commande fournisseur
' ============================================================================
Public Sub PasserCommande()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsAchats As Worksheet
    Set wsAchats = ThisWorkbook.Sheets("Achats")
    
    ' Trouver la prochaine ligne vide
    Dim nextRow As Long
    nextRow = wsAchats.Cells(wsAchats.Rows.Count, "A").End(xlUp).Row + 1
    
    ' Sélection du fournisseur
    Dim wsFournisseurs As Worksheet
    Set wsFournisseurs = ThisWorkbook.Sheets("Fournisseurs")
    
    Dim idFournisseur As Variant
    idFournisseur = InputBox("Entrez l'ID du fournisseur:", "Commande")
    If idFournisseur = "" Or Not IsNumeric(idFournisseur) Then Exit Sub
    
    ' Vérifier que le fournisseur existe
    Dim fournisseurRow As Long
    fournisseurRow = 0
    
    Dim i As Long
    For i = 2 To wsFournisseurs.Cells(wsFournisseurs.Rows.Count, "A").End(xlUp).Row
        If wsFournisseurs.Cells(i, 1).Value = idFournisseur Then
            fournisseurRow = i
            Exit For
        End If
    Next i
    
    If fournisseurRow = 0 Then
        MsgBox "Fournisseur non trouvé!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Informations de la commande
    Dim numCommande As String
    numCommande = InputBox("Numéro de commande:", "Commande")
    
    Dim produit As String
    produit = InputBox("Produit commandé:", "Commande")
    
    Dim quantite As Double
    quantite = CDbl(InputBox("Quantité commandée:", "Commande"))
    
    If quantite <= 0 Then
        MsgBox "La quantité doit être positive!", vbExclamation, "Erreur"
        Exit Sub
    End If
    
    Dim unite As String
    unite = InputBox("Unité de mesure:", "Commande")
    
    Dim prixUnitaire As Double
    prixUnitaire = CDbl(InputBox("Prix unitaire HT:", "Commande"))
    
    Dim dateLivraison As String
    dateLivraison = InputBox("Date de livraison prévue (JJ/MM/AAAA):", "Commande")
    
    ' Calculs
    Dim totalHT As Double
    Dim tvaRate As Double
    Dim totalTTC As Double
    
    tvaRate = 0.20  ' TVA standard 20%
    totalHT = quantite * prixUnitaire
    totalTTC = totalHT * (1 + tvaRate)
    
    ' Enregistrement
    wsAchats.Cells(nextRow, 1).Value = nextRow - 1  ' ID Commande
    wsAchats.Cells(nextRow, 2).Value = Now  ' Date commande
    wsAchats.Cells(nextRow, 3).Value = idFournisseur
    wsAchats.Cells(nextRow, 4).Value = wsFournisseurs.Cells(fournisseurRow, 2).Value  ' Nom Fournisseur
    wsAchats.Cells(nextRow, 5).Value = numCommande
    wsAchats.Cells(nextRow, 6).Value = produit
    wsAchats.Cells(nextRow, 7).Value = quantite
    wsAchats.Cells(nextRow, 8).Value = unite
    wsAchats.Cells(nextRow, 9).Value = prixUnitaire
    wsAchats.Cells(nextRow, 10).Value = totalHT
    wsAchats.Cells(nextRow, 11).Value = tvaRate
    wsAchats.Cells(nextRow, 12).Value = totalTTC
    wsAchats.Cells(nextRow, 13).Value = dateLivraison
    wsAchats.Cells(nextRow, 14).Value = "EN ATTENTE"  ' Statut
    wsAchats.Cells(nextRow, 15).Value = gUserName  ' Utilisateur
    
    Application.ScreenUpdating = True
    MsgBox "✅ Commande enregistrée!" & vbCrLf & _
           "Numéro: " & numCommande & vbCrLf & _
           "Total TTC: " & Format(totalTTC, "#,##0.00") & " €", vbInformation, "Commande"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la commande: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: ReceptionnerCommande
' Description: Marque une commande comme livrée et met à jour le stock
' ============================================================================
Public Sub ReceptionnerCommande()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsAchats As Worksheet
    Set wsAchats = ThisWorkbook.Sheets("Achats")
    
    ' Sélection de la commande
    Dim idCommande As Variant
    idCommande = InputBox("Entrez l'ID de la commande:", "Réception")
    If idCommande = "" Or Not IsNumeric(idCommande) Then Exit Sub
    
    ' Trouver la commande
    Dim commandeRow As Long
    commandeRow = 0
    
    Dim i As Long
    For i = 2 To wsAchats.Cells(wsAchats.Rows.Count, "A").End(xlUp).Row
        If wsAchats.Cells(i, 1).Value = idCommande Then
            commandeRow = i
            Exit For
        End If
    Next i
    
    If commandeRow = 0 Then
        MsgBox "Commande non trouvée!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Vérifier le statut
    If wsAchats.Cells(commandeRow, 14).Value = "LIVREE" Then
        MsgBox "Cette commande a déjà été livrée!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Confirmation
    Dim confirmation As VbMsgBoxResult
    confirmation = MsgBox("Confirmer la réception de la commande:" & vbCrLf & _
                          "Fournisseur: " & wsAchats.Cells(commandeRow, 4).Value & vbCrLf & _
                          "Produit: " & wsAchats.Cells(commandeRow, 6).Value & vbCrLf & _
                          "Quantité: " & wsAchats.Cells(commandeRow, 7).Value & " " & wsAchats.Cells(commandeRow, 8).Value, _
                          vbYesNo + vbQuestion, "Confirmation")
    
    If confirmation = vbNo Then Exit Sub
    
    ' Mettre à jour le statut
    wsAchats.Cells(commandeRow, 14).Value = "LIVREE"
    wsAchats.Cells(commandeRow, 16).Value = Now  ' Date de réception
    
    ' Demander si on veut mettre à jour le stock
    Dim majStock As VbMsgBoxResult
    majStock = MsgBox("Voulez-vous ajouter cette quantité au stock?", _
                      vbYesNo + vbQuestion, "Mise à jour du stock")
    
    If majStock = vbYes Then
        ' Trouver le produit dans le stock
        Dim wsStock As Worksheet
        Set wsStock = ThisWorkbook.Sheets("Stocks")
        
        Dim nomProduit As String
        nomProduit = wsAchats.Cells(commandeRow, 6).Value
        
        Dim produitRow As Long
        produitRow = 0
        
        For i = 2 To wsStock.Cells(wsStock.Rows.Count, "A").End(xlUp).Row
            If wsStock.Cells(i, 3).Value Like "*" & nomProduit & "*" Then
                produitRow = i
                Exit For
            End If
        Next i
        
        If produitRow > 0 Then
            Dim quantite As Double
            quantite = wsAchats.Cells(commandeRow, 7).Value
            
            wsStock.Cells(produitRow, 8).Value = wsStock.Cells(produitRow, 8).Value + quantite
            wsStock.Cells(produitRow, 11).Value = Now
            
            MsgBox "✅ Stock mis à jour!" & vbCrLf & _
                   "Nouveau stock: " & wsStock.Cells(produitRow, 8).Value & " " & _
                   wsStock.Cells(produitRow, 5).Value, vbInformation, "Stock"
        Else
            MsgBox "⚠️ Produit non trouvé dans le stock. Créez-le d'abord.", vbExclamation, "Attention"
        End If
    End If
    
    Application.ScreenUpdating = True
    MsgBox "✅ Commande marquée comme livrée!", vbInformation, "Réception"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la réception: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: AnalyserAchats
' Description: Analyse les achats par fournisseur
' ============================================================================
Public Sub AnalyserAchats()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsAchats As Worksheet
    Dim wsAnalyse As Worksheet
    Set wsAchats = ThisWorkbook.Sheets("Achats")
    
    ' Créer ou réinitialiser la feuille d'analyse
    On Error Resume Next
    Set wsAnalyse = ThisWorkbook.Sheets("Analyse_Achats")
    If wsAnalyse Is Nothing Then
        Set wsAnalyse = ThisWorkbook.Worksheets.Add
        wsAnalyse.Name = "Analyse_Achats"
    Else
        wsAnalyse.Cells.Clear
    End If
    On Error GoTo ErrorHandler
    
    ' En-têtes
    wsAnalyse.Range("A1").Value = "ANALYSE DES ACHATS PAR FOURNISSEUR"
    With wsAnalyse.Range("A1")
        .Font.Bold = True
        .Font.Size = 16
    End With
    wsAnalyse.Range("A1:F1").Merge
    
    wsAnalyse.Range("A3").Value = "Fournisseur"
    wsAnalyse.Range("B3").Value = "Nombre de Commandes"
    wsAnalyse.Range("C3").Value = "Total HT"
    wsAnalyse.Range("D3").Value = "Total TTC"
    wsAnalyse.Range("E3").Value = "% des Achats"
    wsAnalyse.Range("F3").Value = "Statut"
    
    With wsAnalyse.Range("A3:F3")
        .Font.Bold = True
        .Interior.Color = RGB(200, 220, 240)
    End With
    
    ' Calculer les totaux par fournisseur
    Dim dictFournisseurs As Object
    Set dictFournisseurs = CreateObject("Scripting.Dictionary")
    
    Dim totalGeneral As Double
    totalGeneral = 0
    
    Dim lastRow As Long
    lastRow = wsAchats.Cells(wsAchats.Rows.Count, "A").End(xlUp).Row
    
    Dim i As Long
    For i = 2 To lastRow
        Dim fournisseur As String
        Dim totalTTC As Double
        Dim statut As String
        
        fournisseur = wsAchats.Cells(i, 4).Value
        totalTTC = wsAchats.Cells(i, 12).Value
        statut = wsAchats.Cells(i, 14).Value
        
        totalGeneral = totalGeneral + totalTTC
        
        Dim key As String
        key = fournisseur
        
        If Not dictFournisseurs.Exists(key) Then
            dictFournisseurs.Add key, Array(fournisseur, 1, totalTTC, IIf(statut = "LIVREE", 1, 0))
        Else
            Dim data As Variant
            data = dictFournisseurs.Item(key)
            data(1) = data(1) + 1  ' Nombre de commandes
            data(2) = data(2) + totalTTC  ' Total TTC
            If statut = "LIVREE" Then data(3) = data(3) + 1
            dictFournisseurs.Item(key) = data
        End If
    Next i
    
    ' Remplir le tableau
    Dim row As Long
    row = 4
    
    Dim key As Variant
    For Each key In dictFournisseurs.Keys
        Dim data As Variant
        data = dictFournisseurs.Item(key)
        
        wsAnalyse.Cells(row, 1).Value = data(0)
        wsAnalyse.Cells(row, 2).Value = data(1)
        wsAnalyse.Cells(row, 3).Value = data(2) / 1.2  ' Total HT
        wsAnalyse.Cells(row, 4).Value = data(2)
        wsAnalyse.Cells(row, 5).Value = IIf(totalGeneral > 0, data(2) / totalGeneral * 100, 0)
        wsAnalyse.Cells(row, 6).Value = data(3) & "/" & data(1) & " livrées"
        
        wsAnalyse.Cells(row, 4).NumberFormat = "#,##0.00 €"
        wsAnalyse.Cells(row, 3).NumberFormat = "#,##0.00 €"
        wsAnalyse.Cells(row, 5).NumberFormat = "0.00%"
        
        row = row + 1
    Next key
    
    ' Trier par montant décroissant
    wsAnalyse.Range("A3:F" & row).Sort Key1:=wsAnalyse.Range("D3"), Order1:=xlDescending, Header:=xlYes
    
    ' Total général
    wsAnalyse.Cells(row + 1, 1).Value = "TOTAL GÉNÉRAL:"
    wsAnalyse.Cells(row + 1, 1).Font.Bold = True
    wsAnalyse.Cells(row + 1, 4).Value = totalGeneral
    wsAnalyse.Cells(row + 1, 4).Font.Bold = True
    wsAnalyse.Cells(row + 1, 4).NumberFormat = "#,##0.00 €"
    
    ' Ajuster les colonnes
    wsAnalyse.Columns.AutoFit
    
    Application.ScreenUpdating = True
    MsgBox "✅ Analyse des achats générée!" & vbCrLf & _
           "Montant total des achats: " & Format(totalGeneral, "#,##0.00") & " €" & vbCrLf & _
           "Nombre de fournisseurs: " & dictFournisseurs.Count, vbInformation, "Analyse"
    
    wsAnalyse.Select
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'analyse: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: GenererEtatCommandes
' Description: Génère un état des commandes en attente
' ============================================================================
Public Sub GenererEtatCommandes()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsAchats As Worksheet
    Dim wsEtat As Worksheet
    Set wsAchats = ThisWorkbook.Sheets("Achats")
    
    ' Créer ou réinitialiser la feuille d'état
    On Error Resume Next
    Set wsEtat = ThisWorkbook.Sheets("Etat_Commandes")
    If wsEtat Is Nothing Then
        Set wsEtat = ThisWorkbook.Worksheets.Add
        wsEtat.Name = "Etat_Commandes"
    Else
        wsEtat.Cells.Clear
    End If
    On Error GoTo ErrorHandler
    
    ' En-tête
    wsEtat.Range("A1").Value = "ÉTAT DES COMMANDES FOURNISSEURS"
    With wsEtat.Range("A1")
        .Font.Bold = True
        .Font.Size = 16
    End With
    wsEtat.Range("A1:H1").Merge
    
    wsEtat.Range("A3").Value = "ID"
    wsEtat.Range("B3").Value = "Date"
    wsEtat.Range("C3").Value = "Fournisseur"
    wsEtat.Range("D3").Value = "N° Commande"
    wsEtat.Range("E3").Value = "Produit"
    wsEtat.Range("F3").Value = "Quantité"
    wsEtat.Range("G3").Value = "Total TTC"
    wsEtat.Range("H3").Value = "Statut"
    
    With wsEtat.Range("A3:H3")
        .Font.Bold = True
        .Interior.Color = RGB(200, 220, 240)
    End With
    
    ' Filtrer les commandes
    Dim lastRow As Long
    lastRow = wsAchats.Cells(wsAchats.Rows.Count, "A").End(xlUp).Row
    
    Dim row As Long
    row = 4
    Dim countEnAttente As Long
    Dim countLivrees As Long
    
    countEnAttente = 0
    countLivrees = 0
    
    Dim i As Long
    For i = 2 To lastRow
        Dim statut As String
        statut = wsAchats.Cells(i, 14).Value
        
        ' Afficher toutes les commandes
        wsEtat.Cells(row, 1).Value = wsAchats.Cells(i, 1).Value
        wsEtat.Cells(row, 2).Value = Format(wsAchats.Cells(i, 2).Value, "dd/mm/yyyy")
        wsEtat.Cells(row, 3).Value = wsAchats.Cells(i, 4).Value
        wsEtat.Cells(row, 4).Value = wsAchats.Cells(i, 5).Value
        wsEtat.Cells(row, 5).Value = wsAchats.Cells(i, 6).Value
        wsEtat.Cells(row, 6).Value = wsAchats.Cells(i, 7).Value & " " & wsAchats.Cells(i, 8).Value
        wsEtat.Cells(row, 7).Value = wsAchats.Cells(i, 12).Value
        wsEtat.Cells(row, 8).Value = statut
        
        wsEtat.Cells(row, 7).NumberFormat = "#,##0.00 €"
        
        ' Coloration selon le statut
        Select Case statut
            Case "LIVREE"
                wsEtat.Rows(row).Interior.Color = RGB(200, 255, 200)
                countLivrees = countLivrees + 1
            Case "EN ATTENTE"
                wsEtat.Rows(row).Interior.Color = RGB(255, 255, 200)
                countEnAttente = countEnAttente + 1
            Case "ANNULEE"
                wsEtat.Rows(row).Interior.Color = RGB(255, 200, 200)
        End Select
        
        row = row + 1
    Next i
    
    ' Résumé
    wsEtat.Cells(row + 1, 1).Value = "RÉSUMÉ:"
    wsEtat.Cells(row + 1, 1).Font.Bold = True
    wsEtat.Cells(row + 2, 1).Value = "Commandes en attente:"
    wsEtat.Cells(row + 2, 2).Value = countEnAttente
    wsEtat.Cells(row + 3, 1).Value = "Commandes livrées:"
    wsEtat.Cells(row + 3, 2).Value = countLivrees
    
    ' Ajuster les colonnes
    wsEtat.Columns.AutoFit
    
    Application.ScreenUpdating = True
    MsgBox "✅ État des commandes généré!" & vbCrLf & _
           "En attente: " & countEnAttente & vbCrLf & _
           "Livrées: " & countLivrees, vbInformation, "État"
    
    wsEtat.Select
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la génération: " & Err.Description, vbCritical, "Erreur"
End Sub
