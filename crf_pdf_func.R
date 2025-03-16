rm(list = ls())
library(pdftools)
library(purrr)
library(pdftools)
library(tidyverse)
library(stringr)
library(openxlsx)

#Read CRF Page
crf_all <- pdftools::pdf_text("C:/Users/crf.pdf")

#Get the Page Contains Field Name
pgs <-which(!is.na(str_extract(string = crf_all,pattern = "Field Name")))
npgs <-which(is.na(str_extract(string = crf_all,pattern = "Field Name")))

length(pgs)
length(npgs)
length(pgs) + length(npgs)

#Sample Code

#Get the interested page
#Randomly select info
my_pg <- pgs[round(runif(n = 1,min = 1,max = 70))]

#Step : 1 Remove first three lines or start wherever Field name
p1 <- crf_all[[my_pg]] %>% str_split('\\n') %>% unlist() %>% .[-c(1:3)]

#Step : 2 Find where the Pattern is xx ABCSD (one or two numeric, space and CAPITAL)
regexp <- "(\\d{1,2}\\s[A-Z0-9_]{2,20}+)"

p2 <- p1 %>% str_split('\\n') %>% unlist() %>% map_chr(str_squish) %>% str_extract(regexp)%>% map_chr(str_squish)

#Step : 3 Get all NON NA
p2 <- p2 %>% na.omit()%>% as.tibble() %>% mutate(grp=my_pg)


mod <- crf_all[[my_pg]] %>% str_split('\\n') %>% unlist() %>% .[c(1:3)]%>%
       map_chr(str_squish)%>% str_extract("(?<=Form:).*")%>%  map_chr(str_squish) %>% na.omit() %>% as.tibble()

mod$value <- paste0("Form : ",mod$value)
mod
p2


#FUnction in action

 get_crf_vars <- function(my_pg){
   
   #Step : 1 Remove first three lines or start wherever Field name
   p1 <- crf_all[[my_pg]] %>% str_split('\\n') %>% unlist() %>% .[-c(1:3)]
   

   p1 <- p1 %>% str_split('\\n') %>%
                unlist() %>%
                map_chr(str_squish) %>%
                str_extract("(\\d{1,2}\\s[A-Z0-9_]{2,20}+)")%>%
                map_chr(str_squish)
   
   #Step : 3 Get all NON NA
   p1 <- p1 %>%
         na.omit()%>%
         as.tibble() %>% mutate(pg_num=my_pg)
   
   #set form
   mod <- crf_all[[my_pg]] %>% str_split('\\n') %>% unlist() %>% .[2] %>%
     map_chr(str_squish)%>% str_extract("(?<=Form:).*")%>%  map_chr(str_squish) %>% na.omit()
   
   
   p1$form <- mod
   
   return(p1)
 }
 
 gg <- purrr::map_df(pgs,~get_crf_vars(my_pg = .x))
 
 gg <- gg %>% mutate(var_id=as.numeric(str_extract(value,'\\d{1,2}\\s')),
                     var_name=str_extract(value,"(?<=[0-9]\\s).*"))
 
 gg <- gg %>% select(pg_num,form,var_id,var_name)

openxlsx::write.xlsx(x = gg,file = "C:/Users/crf_data.xlsx",
                      asTable = TRUE,overwrite = TRUE)

