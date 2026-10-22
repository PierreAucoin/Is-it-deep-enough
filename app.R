values<-read.csv("model_coefficients.csv")
Sniper_data<-read.csv("sniper_data.csv")
dran_test<-read.csv("dran_values.csv")
# Built Shiny app to show how it would look like

library(shiny)
library(ggplot2)
library(sportyR)
library(dplyr)

ui <- fluidPage(
  titlePanel("Sac Fly Calculator"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("per", label = "Percentage of sucessful sac fly", min = 1, max = 100, value = 100),
      # Dropdown menu to determine who is at which field and who is on third, ordered alphabetically
      selectInput("LF", "Who is in Left Field?", sort(Sniper_data$player)),
      selectInput("CF", "Who is in Center Field?", sort(Sniper_data$player)),
      selectInput("RF", "Who is in Right Field?", sort(Sniper_data$player)),
      selectInput("TB", "Who is on Third Base?", sort(dran_test$player)),
    ),
    mainPanel(
      plotOutput("finalModel"),
      textOutput("lf"),
      textOutput("cf"),
      textOutput("rf")
      
    )
  )
)

server <- function(input, output, session) {
  # Use the values for the fielders selected and the model coefficients to solve for distance given a probility from the slider
  Distance_rf<-reactive({
    key_arm=Sniper_data%>%
      filter(player==input$RF)
    key_run=dran_test%>%
      filter(player==input$TB)
    return(min(c((qlogis(input$per/100)-values[1,2]-values[2,2]*key_arm$Sniper-values[4,2]*key_run$speed)/values[3,2]),353))
  })
  
  Distance_cf<-reactive({
    key_arm=Sniper_data%>%
      filter(player==input$CF)
    key_run=dran_test%>%
      filter(player==input$TB)
    return(min(c((qlogis(input$per/100)-values[1,2]-values[2,2]*key_arm$Sniper-values[4,2]*key_run$speed)/values[3,2]),435))
  })
  
  Distance_lf<-reactive({
    key_arm=Sniper_data%>%
      filter(player==input$LF)
    key_run=dran_test%>%
      filter(player==input$TB)
    return(min(c((qlogis(input$per/100)-values[1,2]-values[2,2]*key_arm$Sniper-values[4,2]*key_run$speed)/values[3,2]),355))
  })
  
  output$lf<-renderText({paste0("The distance the ball must travel is ", round(Distance_lf(),2), " feet to have a ", input$per, " percent chance to be a sac fly in left field")})
  
  output$cf<-renderText({paste0("The distance the ball must travel is ", round(Distance_cf(),2), " feet to have a ", input$per, " percent chance to be a sac fly in center field")})
  
  output$rf<-renderText({paste0("The distance the ball must travel is ", round(Distance_rf(),2), " feet to have a ", input$per, " percent chance to be a sac fly in right field")})
  
  
  # To get the curves correctly, need to convert from polar corrdinates
  # Know that the foul lines are at angles 3pi/4 and pi/4
  # Split that area into three sections
  left_curve_theta<-reactive({
    return(seq(7*pi/12,3*pi/4,by=.01))
  })
  center_curve_theta<-reactive({
    return(seq(5*pi/12,7*pi/12,by=.01))
  })
  right_curve_theta<-reactive({
    return(seq(pi/4,5*pi/12,by=.01))
  })
  # Use distnace and the angle to convert polar coordinates into cartesian corrdinates
  left_curve_x<-reactive({
    return(Distance_lf()*cos(left_curve_theta()))
  })
  left_curve_y<-reactive({
    return(Distance_lf()*sin(left_curve_theta()))
  })
  right_curve_x<-reactive({
    return(Distance_rf()*cos(right_curve_theta()))
  })
  right_curve_y<-reactive({
    return(Distance_rf()*sin(right_curve_theta()))
  })
  center_curve_x<-reactive({
    return(Distance_cf()*cos(center_curve_theta()))
  })
  center_curve_y<-reactive({
    return(Distance_cf()*sin(center_curve_theta()))
  })
  # Plot everything using the new coordinates
  output$finalModel<-renderPlot(geom_baseball(league = "MiLB",field_updates = list(line_width = 2),color_updates = list(foul_line = "#ff5"))+geom_line(aes(x=left_curve_x(),y=left_curve_y()),color="blue",linewidth=1.25)
                                +geom_line(aes(x=right_curve_x(),y=right_curve_y()),color="purple",linewidth=1.25)
                                +geom_line(aes(x=center_curve_x(),y=center_curve_y()),color="gold",linewidth=1.25)
  )
}
shinyApp(ui, server)
