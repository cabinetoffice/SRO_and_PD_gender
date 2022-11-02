library(tidyverse)
library(DBI)
library(odbc)
library(janitor)
library(readxl)
library(scales)
#install.packages(gender)
library(gender)
library(dplyr)
#install.packages("remotes")
#remotes::install_github("lmullen/genderdata")

People <- read_xlsx("S:/GMPP Data/GMPP Standard Shared Query Set/1. New SSQS (SQL)/3. People Data.xlsx", guess_max = 10000) %>% clean_names() %>% 
  select(sro_first_name, pd_first_name, quarter, sro_id, pd_id)



SRO_gender <- drop_na(distinct(select(People,-quarter)))
SRO_gender <- (SRO_gender$sro_first_name[1], method ="ssa")

People_SRO_gender <- left_join(People, SRO_gender, by=list(x="sro_first_name", y="name")) %>% 
  select(- idq,
         -pd_id,
         -pd_first_name,
         first_name=sro_first_name,
         id=sro_id) %>% distinct() %>% mutate(leader="SRO")

PD_gender <- gender(People$pd_first_name, method ="ssa")%>% distinct()

People_PD_gender <- left_join(People, PD_gender, by=list(x="pd_first_name", y="name")) %>% 
  select(- idq,
         -sro_id,
         -sro_first_name,
         first_name=pd_first_name,
         id=pd_id) %>% distinct() %>% mutate(leader="PD")

People_gender <- bind_rows(People_SRO_gender,People_PD_gender) %>% 
  drop_na(first_name)

People_gender %>% 
  write_excel_csv(file="S:/Data Team/Project Delivery Profession/Diversity and Inclusion Dashboard/Gender_SRO_and_PD_2022.csv", col_names = TRUE)