
wydatki1 <- read_excel("wydatki1.xlsx")
colnames(wydatki1) <- c("indeks", "dochod", "wydatki_total", "zywnosc_napoje", "utrzymanie_domu", "rachunki", "transport")

# Funkcja do obliczeń dla modeli
calculateModel <- function(data, response, predictor, bins) {
  model <- lm(I(1/(data[[response]]) ~ I(1/data[[predictor]])))
  a <- 1/model$coefficients[1]
  b <- model$coefficients[2] * a
  ys <- a * data[[predictor]] / (data[[predictor]] + b)
  residuals <- resid(model)
  return(list(model = model, ys = ys, residuals = residuals))
}

# Funkcja do obliczeń dla sumy
calculateSumModel <- function(data, bins) {
  suma <- data$zywnosc_napoje + data$utrzymanie_domu + data$rachunki
  model <- lm(I(1/(suma) ~ I(1/data$dochod)))
  a <- 1/model$coefficients[1]
  b <- model$coefficients[2] * a
  ys <- a * data$dochod / (data$dochod + b)
  residuals <- resid(model)
  return(list(model = model, ys = ys, residuals = residuals))
}

# Funkcja do testu Shapiro-Wilka
shapiroTest <- function(residuals, modelName, alpha) {
  shapiro_test <- shapiro.test(residuals)
  cat(paste("Wynik testu Shapiro-Wilka dla", modelName, ":\n"))
  print(shapiro_test)
  
  if (shapiro_test$p.value < alpha) {
    cat("\nTest Shapiro-Wilka wskazuje, że rozkład reszt nie jest normalny (p <", alpha, ").\n")
    cat("Odrzucamy hipotezę o normalności rozkładu reszt.\n")
  } else {
    cat("\nTest Shapiro-Wilka nie wskazuje istotnych różnic w rozkładzie reszt (p >=", alpha, ").\n")
    cat("Nie ma podstaw do odrzucenia hipotezy o normalności rozkładu reszt.\n")
  }
}

# Funkcja do testu Kołmogorowa-Smirnowa
ksTest <- function(residuals, modelName, alpha = 0.05) {
  ks_test <- ks.test(residuals, "pnorm", mean = mean(residuals), sd = sd(residuals))
  cat(paste("Wynik testu Kołmogorowa-Smirnowa dla", modelName, ":\n"))
  print(ks_test)
  
  if (ks_test$p.value < alpha) {
    cat("\nTest Kołmogorowa-Smirnowa wskazuje, że rozkład reszt nie jest normalny (p <", alpha, ").\n")
    cat("Odrzucamy hipotezę o normalności rozkładu reszt.\n")
  } else {
    cat("\nTest Kołmogorowa-Smirnowa nie wskazuje istotnych różnic w rozkładzie reszt (p >=", alpha, ").\n")
    cat("Nie ma podstaw do odrzucenia hipotezy o normalności rozkładu reszt.\n")
  }
}

# Funkcja do generowania statystyk
generateSummary <- function(residuals, modelName) {
  cat(paste("Statystyki opisowe dla", modelName, ":\n"))
  print(summary(residuals))
}

displayCoefficients <- function(model, modelName) {
  cat(paste("Współczynniki", modelName, ":\n"))
  print(coef(model))
}

shinyServer(function(input, output, session) {
  binsSlider <- sliderInput("bins", "Liczba przedziałów:", min = 1, max = 50, value = 10)
  
  # Model 1
  model1Data <- reactive({
    calculateModel(wydatki1, "zywnosc_napoje", "dochod", input$bins1)
  })
  
  output$plot1 <- renderPlot({
    ggplot(wydatki1, aes(x = dochod, y = zywnosc_napoje)) +
      geom_point(color = "coral") +
      geom_line(aes(y = model1Data()$ys), color = "lightblue", size = 2) +
      labs(x = "Dochód", y = "Wydatki", title = "")
  })
  
  # Wykres histogramu dla Modelu 1
  output$histogram1 <- renderPlot({
    ggplot(wydatki1, aes(x = zywnosc_napoje)) +
      geom_histogram(bins = input$bins1, fill = "lightblue", color = "black", alpha = 0.7) +
      ggtitle("Histogram") +
      labs(x = "Wartość", y = "Częstość") +
      theme_minimal() +
      geom_density(aes(y = ..count.. * input$densityLine1), fill = "transparent", color = "black", linetype = "dashed")
  })
  
  output$model1ShapiroTest <- renderPrint({
    shapiroTest(model1Data()$residuals, "Modelu 1", alpha = as.numeric(input$alpha))
  })
  
  output$model1KSTest <- renderPrint({
    ksTest(model1Data()$residuals, "Modelu 1", alpha = as.numeric(input$alpha))
  })
  
  output$model1Summary <- renderPrint({
    generateSummary(model1Data()$residuals, "Modelu 1")
  })
  
  output$model1Coef <- renderPrint({
    displayCoefficients(model1Data()$model, "Modelu 1")
  })
  
  # Model 2
  model2Data <- reactive({
    calculateModel(wydatki1, "rachunki", "dochod",input$bins2) 
  })
  output$plot2 <- renderPlot({
    ggplot(wydatki1, aes(x = dochod, y = rachunki)) +
      geom_point(color = "coral") +
      geom_line(aes(y = model2Data()$ys), color = "lightblue", size = 2) +
      labs(x = "Dochód", y = "Wydatki", title = "")
  })
  
  # Wykres histogramu dla Modelu 2
  output$histogram2 <- renderPlot({
    ggplot(wydatki1, aes(x = rachunki)) +
      geom_histogram(bins = input$bins2, fill = "lightblue", color = "black", alpha = 0.7) +
      ggtitle("Histogram") +
      labs(x = "Wartość", y = "Częstość") +
      theme_minimal() +
      geom_density(aes(y = ..count.. * input$densityLine2), fill = "transparent", color = "black", linetype = "dashed")
  })
  
  output$model2ShapiroTest <- renderPrint({
    shapiroTest(model2Data()$residuals, "Modelu 2", alpha = as.numeric(input$alpha))
  })
  
  output$model2KSTest <- renderPrint({
    ksTest(model2Data()$residuals, "Modelu 2", alpha = as.numeric(input$alpha))
  })
  
  output$model2Summary <- renderPrint({
    generateSummary(model2Data()$residuals, "Modelu 2")
  })
  output$model2Coef <- renderPrint({
    displayCoefficients(model2Data()$model, "Modelu 2")
  })
  
  
  # Model 3
  model3Data <- reactive({
    calculateModel(wydatki1, "utrzymanie_domu", "dochod", input$bins3)
  })
  output$plot3 <- renderPlot({
    ggplot(wydatki1, aes(x = dochod, y = utrzymanie_domu)) +
      geom_point(color = "coral") +
      geom_line(aes(y = model3Data()$ys), color = "lightblue", size = 2) +
      labs(x = "Dochód", y = "Wydatki", title = "")
  })
  
  # Wykres histogramu dla Modelu 3
  output$histogram3 <- renderPlot({
    ggplot(wydatki1, aes(x = utrzymanie_domu)) +
      geom_histogram(bins = input$bins3, fill = "lightblue", color = "black", alpha = 0.7) +
      ggtitle("Histogram") +
      labs(x = "Wartość", y = "Częstość") +
      theme_minimal() +
      geom_density(aes(y = ..count.. * input$densityLine3), fill = "transparent", color = "black", linetype = "dashed")
  })
  
  
  output$model3ShapiroTest <- renderPrint({
    shapiroTest(model3Data()$residuals, "Modelu 3", alpha = as.numeric(input$alpha))
  })
  
  output$model3KSTest <- renderPrint({
    ksTest(model3Data()$residuals, "Modelu 3", alpha = as.numeric(input$alpha))
  })
  
  output$model3Summary <- renderPrint({
    generateSummary(model3Data()$residuals, "Modelu 3")
  })
  
  output$model3Coef <- renderPrint({
    displayCoefficients(model3Data()$model, "Modelu 3")
  })
  
  # Model Sumy
  modelSumData <- reactive({
    calculateSumModel(wydatki1, input$binsSum)
  })
  output$plotSum <- renderPlot({
    ggplot(wydatki1, aes(x = dochod, y = zywnosc_napoje + utrzymanie_domu + rachunki)) +
      geom_point(color = "coral") +
      geom_line(aes(y = modelSumData()$ys), color = "lightblue", size = 2) +
      labs(x = "Dochód", y = "Wydatki", title = "") 
  })
  
  
  # Wykres histogramu dla Modelu Sumy
  output$histogramSum <- renderPlot({
    ggplot(wydatki1, aes(x = modelSumData()$ys)) +
      geom_histogram(bins = input$binsSum, fill = "lightblue", color = "black", alpha = 0.7) +
      ggtitle("Histogram") +
      labs(x = "Wartość", y = "Częstość") +
      theme_minimal() +
      geom_density(aes(y = ..count.. * input$densityLineSum), fill = "transparent", color = "black", linetype = "dashed")
  })
  
  
  output$modelSumShapiroTest <- renderPrint({
    shapiroTest(modelSumData()$residuals, "Modelu Sumy", alpha = as.numeric(input$alpha))
  })
  
  output$modelSumKSTest <- renderPrint({
    ksTest(modelSumData()$residuals, "Modelu Sumy", alpha = as.numeric(input$alpha))
  })
  
  output$modelSumSummary <- renderPrint({
    generateSummary(modelSumData()$residuals, "Modelu Sumy")
  })
  
  output$modelSumCoef <- renderPrint({
    displayCoefficients(modelSumData()$model, "Modelu Sumy")
  })
})