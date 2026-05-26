' ============================================================================
' MODULE: Module Recettes - Gestion des Recettes et Coûts Matières
' Description: Gestion des fiches techniques, calcul des coûts et marges
' ============================================================================

Option Explicit

' ============================================================================
' PROCEDURE: CreerRecette
' Description: Crée une nouvelle fiche recette
' ============================================================================
Public Sub CreerRecette()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsRecettes As Worksheet
    Set wsRecettes = ThisWorkbook.Sheets("Recettes")
    
    ' Trouver la prochaine ligne vide
    Dim nextRow As Long
    nextRow = wsRecettes.Cells(wsRecettes.Rows.Count, "A").End(xlUp).Row + 1
    
    ' Saisie des informations de la recette
    Dim nomPlat As String
    nomPlat = InputBox("Nom du plat:", "Nouvelle Recette")
    If nomPlat = "" Then Exit Sub
    
    Dim categorie As String
    categorie = InputBox("Catégorie (Entrée, Plat, Dessert):", "Nouvelle Recette")
    
    Dim nbPortions As Double
    nbPortions = CDbl(InputBox("Nombre de portions:", "Nouvelle Recette"))
    
    Dim tempsPreparation As Integer
    tempsPreparation = CInt(InputBox("Temps de préparation (minutes):", "Nouvelle Recette"))
    
    Dim prixVente As Double
    prixVente = CDbl(InputBox("Prix de vente TTC:", "Nouvelle Recette"))
    
    ' Enregistrement des informations principales
    wsRecettes.Cells(nextRow, 1).Value = nextRow - 1  ' ID Recette
    wsRecettes.Cells(nextRow, 2).Value = nomPlat
    wsRecettes.Cells(nextRow, 3).Value = categorie
    wsRecettes.Cells(nextRow, 4).Value = nbPortions
    wsRecettes.Cells(nextRow, 5).Value = tempsPreparation
    wsRecettes.Cells(nextRow, 6).Value = prixVente
    wsRecettes.Cells(nextRow, 7).Value = 0  ' Coût matière (à calculer)
    wsRecettes.Cells(nextRow, 8).Value = 0  ' Marge (à calculer)
    wsRecettes.Cells(nextRow, 9).Value = Now  ' Date création
    
    Application.ScreenUpdating = True
    MsgBox "✅ Recette '" & nomPlat & "' créée!" & vbCrLf & _
           "ID Recette: " & (nextRow - 1) & vbCrLf & _
           "Ajoutez maintenant les ingrédients dans la feuille 'Ingredients_Recettes'", _
           vbInformation, "Recette créée"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la création: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: AjouterIngredientRecette
' Description: Ajoute un ingrédient à une recette
' ============================================================================
Public Sub AjouterIngredientRecette()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsIngredients As Worksheet
    Set wsIngredients = ThisWorkbook.Sheets("Ingredients_Recettes")
    
    ' Trouver la prochaine ligne vide
    Dim nextRow As Long
    nextRow = wsIngredients.Cells(wsIngredients.Rows.Count, "A").End(xlUp).Row + 1
    
    ' Sélection de la recette
    Dim idRecette As Variant
    idRecette = InputBox("Entrez l'ID de la recette:", "Ajout Ingrédient")
    If idRecette = "" Or Not IsNumeric(idRecette) Then Exit Sub
    
    ' Sélection du produit/ingrédient
    Dim wsStock As Worksheet
    Set wsStock = ThisWorkbook.Sheets("Stocks")
    
    Dim idProduit As Variant
    idProduit = InputBox("Entrez l'ID du produit/ingrédient:", "Ajout Ingrédient")
    If idProduit = "" Or Not IsNumeric(idProduit) Then Exit Sub
    
    ' Vérifier que le produit existe
    Dim produitRow As Long
    produitRow = 0
    
    Dim i As Long
    For i = 2 To wsStock.Cells(wsStock.Rows.Count, "A").End(xlUp).Row
        If wsStock.Cells(i, 1).Value = idProduit Then
            produitRow = i
            Exit For
        End If
    Next i
    
    If produitRow = 0 Then
        MsgBox "Produit non trouvé!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Quantité nécessaire
    Dim quantite As Double
    quantite = CDbl(InputBox("Quantité nécessaire pour la recette:", "Ajout Ingrédient"))
    
    If quantite <= 0 Then
        MsgBox "La quantité doit être positive!", vbExclamation, "Erreur"
        Exit Sub
    End If
    
    ' Unité de mesure
    Dim unite As String
    unite = InputBox("Unité de mesure (g, kg, ml, L, unité):", "Ajout Ingrédient")
    
    ' Enregistrement
    wsIngredients.Cells(nextRow, 1).Value = nextRow - 1  ' ID
    wsIngredients.Cells(nextRow, 2).Value = idRecette  ' ID Recette
    wsIngredients.Cells(nextRow, 3).Value = idProduit  ' ID Produit
    wsIngredients.Cells(nextRow, 4).Value = wsStock.Cells(produitRow, 3).Value  ' Nom Produit
    wsIngredients.Cells(nextRow, 5).Value = quantite
    wsIngredients.Cells(nextRow, 6).Value = unite
    wsIngredients.Cells(nextRow, 7).Value = wsStock.Cells(produitRow, 6).Value  ' Prix d'achat
    wsIngredients.Cells(nextRow, 8).Value = CalculerCoutIngredient(quantite, unite, wsStock.Cells(produitRow, 6).Value, wsStock.Cells(produitRow, 5).Value)
    wsIngredients.Cells(nextRow, 9).Value = Now
    
    Application.ScreenUpdating = True
    MsgBox "✅ Ingrédient ajouté!" & vbCrLf & _
           "Coût de cet ingrédient: " & Format(wsIngredients.Cells(nextRow, 8).Value, "#,##0.00") & " €", _
           vbInformation, "Ingrédient ajouté"
    
    ' Mettre à jour le coût total de la recette
    Call CalculerCoutRecette(CLng(idRecette))
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'ajout: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' FUNCTION: CalculerCoutIngredient
' Description: Calcule le coût d'un ingrédient dans une recette
' ============================================================================
Public Function CalculerCoutIngredient(quantite As Double, uniteRecette As String, _
                                       prixAchat As Double, uniteAchat As String) As Double
    On Error GoTo ErrorHandler
    
    Dim facteurConversion As Double
    facteurConversion = 1
    
    ' Conversion des unités
    Select Case LCase(uniteAchat)
        Case "kg"
            Select Case LCase(uniteRecette)
                Case "g": facteurConversion = 1000
                Case "kg": facteurConversion = 1
            End Select
        Case "l"
            Select Case LCase(uniteRecette)
                Case "ml": facteurConversion = 1000
                Case "l": facteurConversion = 1
            End Select
        Case "unite", "unité"
            facteurConversion = 1
    End Select
    
    ' Calcul du coût
    CalculerCoutIngredient = (quantite / facteurConversion) * prixAchat
    
    Exit Function
    
ErrorHandler:
    CalculerCoutIngredient = 0
End Function

' ============================================================================
' PROCEDURE: CalculerCoutRecette
' Description: Calcule le coût total d'une recette
' ============================================================================
Public Sub CalculerCoutRecette(idRecette As Long)
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsIngredients As Worksheet
    Dim wsRecettes As Worksheet
    Set wsIngredients = ThisWorkbook.Sheets("Ingredients_Recettes")
    Set wsRecettes = ThisWorkbook.Sheets("Recettes")
    
    ' Trouver la recette
    Dim recetteRow As Long
    recetteRow = 0
    
    Dim i As Long
    For i = 2 To wsRecettes.Cells(wsRecettes.Rows.Count, "A").End(xlUp).Row
        If wsRecettes.Cells(i, 1).Value = idRecette Then
            recetteRow = i
            Exit For
        End If
    Next i
    
    If recetteRow = 0 Then
        MsgBox "Recette non trouvée!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Somme des coûts des ingrédients
    Dim coutTotal As Double
    coutTotal = 0
    
    Dim lastRow As Long
    lastRow = wsIngredients.Cells(wsIngredients.Rows.Count, "A").End(xlUp).Row
    
    For i = 2 To lastRow
        If wsIngredients.Cells(i, 2).Value = idRecette Then
            coutTotal = coutTotal + wsIngredients.Cells(i, 8).Value
        End If
    Next i
    
    ' Mettre à jour la recette
    wsRecettes.Cells(recetteRow, 7).Value = coutTotal
    
    ' Calculer la marge
    Dim prixVente As Double
    Dim prixVenteHT As Double
    Dim marge As Double
    Dim tauxMarge As Double
    
    prixVente = wsRecettes.Cells(recetteRow, 6).Value
    prixVenteHT = prixVente / 1.10  ' TVA 10%
    
    If prixVenteHT > 0 Then
        marge = prixVenteHT - coutTotal
        tauxMarge = (marge / prixVenteHT) * 100
    Else
        marge = 0
        tauxMarge = 0
    End If
    
    wsRecettes.Cells(recetteRow, 8).Value = tauxMarge
    wsRecettes.Cells(recetteRow, 10).Value = Now  ' Date mise à jour
    
    Application.ScreenUpdating = True
    MsgBox "✅ Coût de la recette calculé!" & vbCrLf & _
           "Coût matière: " & Format(coutTotal, "#,##0.00") & " €" & vbCrLf & _
           "Marge: " & Format(tauxMarge, "0.00") & "%", vbInformation, "Calcul terminé"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors du calcul: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: AnalyserMarges
' Description: Analyse les marges de toutes les recettes
' ============================================================================
Public Sub AnalyserMarges()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsRecettes As Worksheet
    Dim wsAnalyse As Worksheet
    Set wsRecettes = ThisWorkbook.Sheets("Recettes")
    
    ' Créer ou réinitialiser la feuille d'analyse
    On Error Resume Next
    Set wsAnalyse = ThisWorkbook.Sheets("Analyse_Marges")
    If wsAnalyse Is Nothing Then
        Set wsAnalyse = ThisWorkbook.Worksheets.Add
        wsAnalyse.Name = "Analyse_Marges"
    Else
        wsAnalyse.Cells.Clear
    End If
    On Error GoTo ErrorHandler
    
    ' En-têtes
    wsAnalyse.Range("A1").Value = "ANALYSE DES MARGES PAR PLAT"
    With wsAnalyse.Range("A1")
        .Font.Bold = True
        .Font.Size = 16
    End With
    wsAnalyse.Range("A1:H1").Merge
    
    wsAnalyse.Range("A3").Value = "Plat"
    wsAnalyse.Range("B3").Value = "Catégorie"
    wsAnalyse.Range("C3").Value = "Prix Vente TTC"
    wsAnalyse.Range("D3").Value = "Prix Vente HT"
    wsAnalyse.Range("E3").Value = "Coût Matière"
    wsAnalyse.Range("F3").Value = "Marge Brute"
    wsAnalyse.Range("G3").Value = "Taux de Marge %"
    wsAnalyse.Range("H3").Value = "Conseil"
    
    With wsAnalyse.Range("A3:H3")
        .Font.Bold = True
        .Interior.Color = RGB(200, 220, 240)
    End With
    
    ' Remplir les données
    Dim lastRow As Long
    lastRow = wsRecettes.Cells(wsRecettes.Rows.Count, "A").End(xlUp).Row
    
    Dim row As Long
    row = 4
    
    Dim i As Long
    For i = 2 To lastRow
        Dim nomPlat As String
        Dim categorie As String
        Dim prixTTC As Double
        Dim prixHT As Double
        Dim coutMatiere As Double
        Dim margeBrute As Double
        Dim tauxMarge As Double
        Dim conseil As String
        
        nomPlat = wsRecettes.Cells(i, 2).Value
        categorie = wsRecettes.Cells(i, 3).Value
        prixTTC = wsRecettes.Cells(i, 6).Value
        coutMatiere = wsRecettes.Cells(i, 7).Value
        tauxMarge = wsRecettes.Cells(i, 8).Value
        
        prixHT = prixTTC / 1.10
        margeBrute = prixHT - coutMatiere
        
        ' Déterminer un conseil
        If tauxMarge >= 70 Then
            conseil = "Excellent ✅"
        ElseIf tauxMarge >= 60 Then
            conseil = "Bon 👍"
        ElseIf tauxMarge >= 50 Then
            conseil = "Correct ⚠️"
        Else
            conseil = "À revoir ❌"
        End If
        
        wsAnalyse.Cells(row, 1).Value = nomPlat
        wsAnalyse.Cells(row, 2).Value = categorie
        wsAnalyse.Cells(row, 3).Value = prixTTC
        wsAnalyse.Cells(row, 4).Value = prixHT
        wsAnalyse.Cells(row, 5).Value = coutMatiere
        wsAnalyse.Cells(row, 6).Value = margeBrute
        wsAnalyse.Cells(row, 7).Value = tauxMarge
        wsAnalyse.Cells(row, 8).Value = conseil
        
        ' Coloration conditionnelle
        If tauxMarge >= 70 Then
            wsAnalyse.Rows(row).Interior.Color = RGB(200, 255, 200)
        ElseIf tauxMarge >= 60 Then
            wsAnalyse.Rows(row).Interior.Color = RGB(230, 255, 230)
        ElseIf tauxMarge >= 50 Then
            wsAnalyse.Rows(row).Interior.Color = RGB(255, 255, 200)
        Else
            wsAnalyse.Rows(row).Interior.Color = RGB(255, 200, 200)
        End If
        
        row = row + 1
    Next i
    
    ' Formatage des nombres
    wsAnalyse.Range("C3:F" & row).NumberFormat = "#,##0.00 €"
    wsAnalyse.Range("G3:G" & row).NumberFormat = "0.00%"
    
    ' Ajuster les colonnes
    wsAnalyse.Columns.AutoFit
    
    Application.ScreenUpdating = True
    MsgBox "✅ Analyse des marges générée!" & vbCrLf & _
           "Nombre de plats analysés: " & (row - 4), vbInformation, "Analyse"
    
    wsAnalyse.Select
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de l'analyse: " & Err.Description, vbCritical, "Erreur"
End Sub

' ============================================================================
' PROCEDURE: ImprimerFicheTechnique
' Description: Génère une fiche technique imprimable pour une recette
' ============================================================================
Public Sub ImprimerFicheTechnique()
    On Error GoTo ErrorHandler
    
    Application.ScreenUpdating = False
    
    Dim wsRecettes As Worksheet
    Dim wsFiche As Worksheet
    Set wsRecettes = ThisWorkbook.Sheets("Recettes")
    
    ' Sélection de la recette
    Dim idRecette As Variant
    idRecette = InputBox("Entrez l'ID de la recette:", "Fiche Technique")
    If idRecette = "" Or Not IsNumeric(idRecette) Then Exit Sub
    
    ' Trouver la recette
    Dim recetteRow As Long
    recetteRow = 0
    
    Dim i As Long
    For i = 2 To wsRecettes.Cells(wsRecettes.Rows.Count, "A").End(xlUp).Row
        If wsRecettes.Cells(i, 1).Value = idRecette Then
            recetteRow = i
            Exit For
        End If
    Next i
    
    If recetteRow = 0 Then
        MsgBox "Recette non trouvée!", vbExclamation, "Attention"
        Exit Sub
    End If
    
    ' Créer la fiche
    On Error Resume Next
    Set wsFiche = ThisWorkbook.Sheets("Fiche_Technique")
    If wsFiche Is Nothing Then
        Set wsFiche = ThisWorkbook.Worksheets.Add
        wsFiche.Name = "Fiche_Technique"
    End If
    On Error GoTo ErrorHandler
    
    wsFiche.Cells.Clear
    
    ' En-tête
    With wsFiche.Range("A1")
        .Value = "FICHE TECHNIQUE"
        .Font.Bold = True
        .Font.Size = 20
        .HorizontalAlignment = xlCenter
    End With
    wsFiche.Range("A1:F1").Merge
    
    ' Informations de la recette
    wsFiche.Range("A3").Value = "Plat:"
    wsFiche.Range("B3").Value = wsRecettes.Cells(recetteRow, 2).Value
    wsFiche.Range("B3").Font.Bold = True
    
    wsFiche.Range("A4").Value = "Catégorie:"
    wsFiche.Range("B4").Value = wsRecettes.Cells(recetteRow, 3).Value
    
    wsFiche.Range("A5").Value = "Nombre de portions:"
    wsFiche.Range("B5").Value = wsRecettes.Cells(recetteRow, 4).Value
    
    wsFiche.Range("A6").Value = "Temps de préparation:"
    wsFiche.Range("B6").Value = wsRecettes.Cells(recetteRow, 5).Value & " minutes"
    
    wsFiche.Range("A8").Value = "PRIX DE VENTE:"
    wsFiche.Range("B8").Value = wsRecettes.Cells(recetteRow, 6).Value & " € TTC"
    wsFiche.Range("B8").Font.Bold = True
    wsFiche.Range("B8").Font.Size = 14
    
    ' Liste des ingrédients
    wsFiche.Range("A10").Value = "INGRÉDIENTS"
    wsFiche.Range("A10").Font.Bold = True
    wsFiche.Range("A10").Interior.Color = RGB(200, 220, 240)
    
    wsFiche.Range("A11").Value = "Ingrédient"
    wsFiche.Range("B11").Value = "Quantité"
    wsFiche.Range("C11").Value = "Coût"
    
    With wsFiche.Range("A11:C11")
        .Font.Bold = True
        .Interior.Color = RGB(220, 230, 240)
    End With
    
    ' Remplir les ingrédients
    Dim wsIngredients As Worksheet
    Set wsIngredients = ThisWorkbook.Sheets("Ingredients_Recettes")
    
    Dim ingredientRow As Long
    ingredientRow = 12
    
    Dim coutTotal As Double
    coutTotal = 0
    
    Dim lastRow As Long
    lastRow = wsIngredients.Cells(wsIngredients.Rows.Count, "A").End(xlUp).Row
    
    For i = 2 To lastRow
        If wsIngredients.Cells(i, 2).Value = idRecette Then
            wsFiche.Cells(ingredientRow, 1).Value = wsIngredients.Cells(i, 4).Value
            wsFiche.Cells(ingredientRow, 2).Value = wsIngredients.Cells(i, 5).Value & " " & wsIngredients.Cells(i, 6).Value
            wsFiche.Cells(ingredientRow, 3).Value = wsIngredients.Cells(i, 8).Value
            wsFiche.Cells(ingredientRow, 3).NumberFormat = "#,##0.00 €"
            
            coutTotal = coutTotal + wsIngredients.Cells(i, 8).Value
            ingredientRow = ingredientRow + 1
        End If
    Next i
    
    ' Total
    wsFiche.Cells(ingredientRow + 1, 1).Value = "COÛT MATIÈRE TOTAL:"
    wsFiche.Cells(ingredientRow + 1, 1).Font.Bold = True
    wsFiche.Cells(ingredientRow + 1, 2).Value = coutTotal
    wsFiche.Cells(ingredientRow + 1, 2).NumberFormat = "#,##0.00 €"
    wsFiche.Cells(ingredientRow + 1, 2).Font.Bold = True
    
    wsFiche.Cells(ingredientRow + 2, 1).Value = "COÛT PAR PORTION:"
    wsFiche.Cells(ingredientRow + 2, 2).Value = coutTotal / wsRecettes.Cells(recetteRow, 4).Value
    wsFiche.Cells(ingredientRow + 2, 2).NumberFormat = "#,##0.00 €"
    
    ' Ajuster les colonnes
    wsFiche.Columns.AutoFit
    
    Application.ScreenUpdating = True
    MsgBox "✅ Fiche technique générée!" & vbCrLf & _
           "Consultez la feuille 'Fiche_Technique' pour impression", vbInformation, "Fiche technique"
    
    wsFiche.Select
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Erreur lors de la génération: " & Err.Description, vbCritical, "Erreur"
End Sub
