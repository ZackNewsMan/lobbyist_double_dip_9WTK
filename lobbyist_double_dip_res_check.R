############################# check if false resolution match ############

inner_join(opp_lobbyist, supp_lobbyist, by = c("bill_id" = "bill_id", "bill_type" = "bill_type","bill_information" = "bill_information","lobbyist_name" = "lobbyist_name")) %>% 
  View()


inner_join(opp_lobbyist, supp_lobbyist, by = c("bill_id" = "bill_id", "bill_type" = "bill_type","bill_information" = "bill_information","lobbyist_name" = "lobbyist_name")) %>% 
  select(lobbyist_name, bill_type, bill_id, bill_information, client_name.x, lobbyist_activity_description.x, position_start_date.x, position_end_date.x, client_name.y,lobbyist_activity_description.y, position_start_date.y, position_end_date.y) %>% 
  View()


# That worked swimmingly. :) 

pre_rename_client_position_change_check_2 <- inner_join(opp_lobbyist, supp_lobbyist, by = c("bill_id" = "bill_id", "bill_type" = "bill_type","bill_information" = "bill_information","lobbyist_name" = "lobbyist_name")) %>% 
  select(lobbyist_name, bill_type, bill_id, bill_information, client_name.x, lobbyist_activity_description.x, position_start_date.x, position_end_date.x, client_name.y,lobbyist_activity_description.y, position_start_date.y, position_end_date.y)

# Renaming some columns to make it easier to work with. 

pre_rename_client_position_change_check_2 %>% 
  rename(opp_client = client_name.x,
         opp_position = lobbyist_activity_description.x,
         opp_position_start_date = position_start_date.x,
         opp_position_end_date = position_end_date.x,
         supp_client = client_name.y,
         supp_position = lobbyist_activity_description.y,
         supp_position_start_date = position_start_date.y,
         supp_position_end_date = position_end_date.y)

rename_client_position_change_check_2 <- 
  pre_rename_client_position_change_check_2 %>% 
  rename(opp_client = client_name.x,
         opp_position = lobbyist_activity_description.x,
         opp_position_start_date = position_start_date.x,
         opp_position_end_date = position_end_date.x,
         supp_client = client_name.y,
         supp_position = lobbyist_activity_description.y,
         supp_position_start_date = position_start_date.y,
         supp_position_end_date = position_end_date.y)

flip_flop_2 <- rename_client_position_change_check_2 %>% 
  filter(opp_client != supp_client)

# By distinct bill numbers 

flip_flop_2 %>% 
  distinct(bill_id, .keep_all = TRUE) %>% 
  View()

# There are instances of lobbyists both supporting and opposing a bill. But it's unclear if that flip-flopping happened at the same time. 

# If Bill ID is blank, that means they worked for an org before it formally became a bill. Need to eliminate. 

flip_flop_2 %>% 
  filter(!is.na(bill_id)) %>% 
  View()

# Doing that made the number of rows from my SQL queries, 2,252, align with what R was showing. 
# Before that query, R had artificially inflated matches with blanks in the bill ID column. 

non_blank_flip_flop_2 <- flip_flop_2 %>% 
  filter(!is.na(bill_id)) 

non_blank_flip_flop_2 %>% 
  distinct(lobbyist_name, .keep_all = TRUE)


non_blank_flip_flop_2 %>% write_csv("non_blank_flip_flop_2.csv", na = "")


# I am sure there is a way to pull out dates with lubridate in R, but I just wanted to pull them out in a way that I can trust quickly. 
# =TEXT(M2, "YYYY")
# Will reimport. 

years_non_blank_flip_flop_2 <- non_blank_flip_flop_2

years_non_blank_flip_flop_2 %>% 
  filter(supp_position_start_year == opp_position_start_year) %>% 
  filter(supp_position_start_date <= opp_position_end_date | opp_position_start_date <= supp_position_end_date) %>% 
  View()

# Worked!
# I will need to do the inverse to get the other side of it. 

years_non_blank_flip_flop_2 %>% 
  filter(supp_position_start_year == opp_position_start_year) %>% 
  filter(opp_position_start_date <= supp_position_end_date | supp_position_start_date <= opp_position_end_date) %>% 
  View()

  # OFF BY A COUPLE ROWS, 409 TO 414 

   supp_opp_yr_check <- years_non_blank_flip_flop_2 %>% 
    filter(supp_position_start_year == opp_position_start_year) %>% 
    filter(supp_position_start_date <= opp_position_end_date | opp_position_start_date <= supp_position_end_date)
  
  
   opp_supp_yr_check <- years_non_blank_flip_flop_2 %>% 
     filter(supp_position_start_year == opp_position_start_year) %>% 
     filter(opp_position_start_date <= supp_position_end_date | supp_position_start_date <= opp_position_end_date)
   
  supp_opp_yr_check %>% anti_join(opp_supp_yr_check)
  
  opp_supp_yr_check %>% anti_join(supp_opp_yr_check)
  
   # just kidding. I had mislabeled it and it showed me the old query instead of the new one.We good. 414 rows in this new edition. 
  
  # for ongoing: 
  years_non_blank_flip_flop_2 %>% 
    filter(supp_position_start_year == opp_position_start_year) %>%
    filter((supp_position_start_date < opp_position_end_date | opp_position_start_date < supp_position_end_date) & (opp_position_end_date == "Ongoing"| supp_position_end_date == "Ongoing")) %>% 
    filter(!(opp_position_end_date < supp_position_start_date)) %>% 
    View()
  
  # Later in the code I realized that I didn't need to do above. I will group next
  
  years_non_blank_flip_flop_2 %>% 
  group_by(lobbyist_name, opp_client, supp_client, bill_id, opp_position_start_date, opp_position_end_date, supp_position_start_date, supp_position_end_date) %>% 
    summarize(count = n()) %>% 
    View()
  