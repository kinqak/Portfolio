
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(DT)
library(readxl)

ui <- dashboardPage(
  dashboardHeader(
    title = "Modelowanie ekonometryczne",
    titleWidth = 400
  ),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Model 1", tabName = "model1", icon = icon("line-chart")),
      menuItem("Model 2", tabName = "model2", icon = icon("line-chart")),
      menuItem("Model 3", tabName = "model3", icon = icon("line-chart")),
      menuItem("Model Sumy", tabName = "modelSum", icon = icon("line-chart")),
      selectInput("alpha", "Poziom istotności:", c("0.01" = 0.01, "0.1" = 0.1, "0.5" = 0.5), selected = 0.05)
    )
  ),
  
  dashboardBody(
    tags$style(HTML("
  body {
    background-color: #B0C4DE;
  }

  .main-header .logo {
    background-color: #FFFFFF;
  }

  .main-header .logo:hover {
    background-color: #FFFFFF;
  }

  .main-header .navbar {
    background-color: #FFFFFF;
  }

  .main-sidebar {
    background-color: #C0C0C0;
  }

  .main-sidebar a:hover {
    background-color: #F5F5F5;
  }

  .content-wrapper, .right-side {
    background-color: #FFFFFF;
  }

  .box.box-solid.box-default {
    border: 2px solid #FF9DA7;
  }

  .box.box-solid.box-default .box-header {
    background: #9C755F;
    border-bottom: 2px solid #FF9DA7;
    color: #fff;
  }

  .box.box-solid.box-default .box-footer {
    border-top: 2px solid #FF9DA7;
  }
")),
    tabItems(
      tabItem("model1",
              fluidRow(
                column(12, h1("Model ekonometryczny wydatków na żywność i napoje bezalkoholowe w zależności od dochodu", style = "font-size: 18px; text-align: center;font-weight: bold")),
                column(6, plotOutput("plot1", width = "100%", height = "500px")),
                column(6,
                       plotOutput("histogram1", width = "100%", height = "450px"),
                       sliderInput("bins1", "Liczba przedziałów:", min = 1, max = 50, value = 10),
                       checkboxInput("densityLine1", "Dodaj linię gęstości", value = FALSE)
                       
                )
              ),
              tabsetPanel(
                tabPanel("Współczynniki modelu", verbatimTextOutput("model1Coef")),
                tabPanel("Statystyki opisowe", verbatimTextOutput("model1Summary")),
                tabPanel("Test Shapiro-Wilka", verbatimTextOutput("model1ShapiroTest")),
                tabPanel("Test Kołmogorova-Smirnova", verbatimTextOutput("model1KSTest"))
              )
      ),
      
      tabItem("model2",
              fluidRow(
                column(12, h1("Model ekonometryczny wydatków na rachunki w zależności od dochodu", style = "font-size: 18px; text-align: center;font-weight: bold")),
                column(6, plotOutput("plot2", width = "100%", height = "500px")),
                column(6,
                       plotOutput("histogram2", width = "100%", height = "450px"),
                       sliderInput("bins2", "Liczba przedziałów:", min = 1, max = 50, value = 10),
                       checkboxInput("densityLine2", "Dodaj linię gęstości", value = FALSE)
                       
                )
              ),
              tabsetPanel(
                tabPanel("Współczynniki modelu", verbatimTextOutput("model2Coef")),
                tabPanel("Statystyki opisowe", verbatimTextOutput("model2Summary")),
                tabPanel("Test Shapiro-Wilka", verbatimTextOutput("model2ShapiroTest")),
                tabPanel("Test Kołmogorova-Smirnova", verbatimTextOutput("model2KSTest"))
              )
      ),
      
      tabItem("model3",
              fluidRow(
                column(12, h1("Model ekonometryczny wydatków na utrzymanie domu w zależności od dochodu", style = "font-size: 18px; text-align: center;font-weight: bold")),
                column(6, plotOutput("plot3", width = "100%", height = "500px")),
                column(6,
                       plotOutput("histogram3", width = "100%", height = "450px"),
                       sliderInput("bins3", "Liczba przedziałów:", min = 1, max = 50, value = 10),
                       checkboxInput("densityLine3", "Dodaj linię gęstości", value = FALSE)
                       
                )
              ),
              tabsetPanel(
                tabPanel("Współczynniki modelu", verbatimTextOutput("model3Coef")),
                tabPanel("Statystyki opisowe", verbatimTextOutput("model3Summary")),
                tabPanel("Test Shapiro-Wilka", verbatimTextOutput("model3ShapiroTest")),
                tabPanel("Test Kołmogorova-Smirnova", verbatimTextOutput("model3KSTest"))
              )
      ),
      
      tabItem("modelSum",
              fluidRow(
                column(12, h1("Model ekonometryczny sumy wydatków na żywność i napoje, rachunki, utrzymanie domu w zależności od dochodu", style = "font-size: 18px; text-align: center;font-weight: bold")),
                column(6, plotOutput("plotSum", width = "100%", height = "500px")),
                column(6,
                       plotOutput("histogramSum", width = "100%", height = "450px"),
                       sliderInput("binsSum", "Liczba przedziałów:", min = 1, max = 50, value = 10),
                       checkboxInput("densityLineSum", "Dodaj linię gęstości", value = FALSE)
                       
                )
              ),
              tabsetPanel(
                tabPanel("Współczynniki modelu", verbatimTextOutput("modelSumCoef")),
                tabPanel("Statystyki opisowe", verbatimTextOutput("modelSumSummary")),
                tabPanel("Test Shapiro-Wilka", verbatimTextOutput("modelSumShapiroTest")),
                tabPanel("Test Kołmogorova-Smirnova", verbatimTextOutput("modelSumKSTest"))
              )
      )
    )
  ),
  skin = "black"
)
