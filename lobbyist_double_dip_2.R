library(tidyverse)

lobbyist <- lobbyist_disclosure_subjects_and_bills

opp_lobbyist <- lobbyist %>% 
  filter(lobbyist_activity_description == "Opposing")

supp_lobbyist <- lobbyist %>% 
  filter(lobbyist_activity_description == "Supporting")

# These ideas didn't work:

        inner_join(opp_lobbyist, supp_lobbyist, by = "lobbyist_name" & "bill_id") %>% 
          View()
        
        opp_lobbyist %>% inner_join(supp_lobbyist)
        
        inner_join(opp_lobbyist, supp_lobbyist, by.x = "lobbyist_name", by.y = "bill_id")
        
        
        opp_lobbyist %>%
          inner_join(supp_lobbyist, by = c("bill_id" == "bill_id", "lobbyist_name" == "lobbyist_name"))
        
        opp_lobbyist %>% 
          inner_join(supp_lobbyist, by = "bill_id" == "bill_id", "lobbyist_name" == "lobbyist_name")

# This finally worked!!!!
  # Inso: left_join(fdata, sdata, by = c("fyear" >= "byear","fyear" < "eyear"))
        # https://stackoverflow.com/questions/37289405/dplyr-left-join-by-less-than-greater-than-condition
              
  inner_join(opp_lobbyist, supp_lobbyist, by = c("bill_id" = "bill_id", "lobbyist_name" = "lobbyist_name"))

  # 35,894 rows, which is way more than SQL found. 
    # SQL: 
  
      # CREATE TABLE opp AS
      # SELECT lobbyist_name, bill_id, lobbyist_activity_description
      # FROM lobbyist
      # WHERE lobbyist_activity_description = "Opposing"
      
      # CREATE TABLE supp AS 
      # SELECT lobbyist_name, bill_id, lobbyist_activity_description
      # FROM lobbyist
      # WHERE lobbyist_activity_description = "Supporting"
      
      # SELECT *
      #   FROM opp, supp
      # WHERE opp.bill_id = supp.bill_id
      # AND opp.lobbyist_name = supp.lobbyist_name
      
      
  inner_join(opp_lobbyist, supp_lobbyist, by = c("bill_id" = "bill_id", "lobbyist_name" = "lobbyist_name")) %>% 
    View()

  # Too many columns. This will limit it:
  
  inner_join(opp_lobbyist, supp_lobbyist, by = c("bill_id" = "bill_id", "lobbyist_name" = "lobbyist_name")) %>% 
    select(lobbyist_name, bill_id, client_name.x, lobbyist_activity_description.x, position_start_date.x, position_end_date.x, client_name.y,lobbyist_activity_description.y, position_start_date.y, position_end_date.y) 
  
    # That worked swimmingly. :) 
  
      pre_rename_client_position_change_check <- inner_join(opp_lobbyist, supp_lobbyist, by = c("bill_id" = "bill_id", "lobbyist_name" = "lobbyist_name")) %>% 
            select(lobbyist_name, bill_id, client_name.x, lobbyist_activity_description.x, position_start_date.x, position_end_date.x, client_name.y,lobbyist_activity_description.y, position_start_date.y, position_end_date.y) 
          
    # Renaming some columns to make it easier to work with. 
  
      pre_rename_client_position_change_check %>% 
        rename(opp_client = client_name.x,
               opp_position = lobbyist_activity_description.x,
               opp_position_start_date = position_start_date.x,
               opp_position_end_date = position_end_date.x,
               supp_client = client_name.y,
               supp_position = lobbyist_activity_description.y,
               supp_position_start_date = position_start_date.y,
               supp_position_end_date = position_end_date.y)
      
      # Worked! 
        # Put new column name (one that you're changing it to) first. Then what it's changing from.
        # Inspo: https://www.marsja.se/how-to-rename-column-or-columns-in-r-with-dplyr/
      
      
      rename_client_position_change_check <- pre_rename_client_position_change_check %>% 
        rename(opp_client = client_name.x,
               opp_position = lobbyist_activity_description.x,
               opp_position_start_date = position_start_date.x,
               opp_position_end_date = position_end_date.x,
               supp_client = client_name.y,
               supp_position = lobbyist_activity_description.y,
               supp_position_start_date = position_start_date.y,
               supp_position_end_date = position_end_date.y)
      
      # SQL:
        # CREATE TABLE client_position_change_check2 AS
        # SELECT opp2.lobbyist_name as "opp_lobbyist", opp2.bill_id AS "opp_bill_id", opp2.client_name as "opp_client", opp2.lobbyist_activity_description as "opp_position", supp2.lobbyist_name as "supp_lobbyist", supp2.bill_id as "supp_bill_id", supp2.client_name as "supp_client", supp2.lobbyist_activity_description as "supp_position" 
        # FROM opp2, supp2
        # WHERE opp2.bill_id = supp2.bill_id
        # AND opp2.lobbyist_name = supp2.lobbyist_name
  
  # Now we need to find times when the opposing and supporting clients were different
      
      rename_client_position_change_check %>% 
        filter(opp_client != supp_client)

      # Worked!
        # SQL:
        # CREATE TABLE "flip_flop3" AS
        # SELECT *
        # FROM client_position_change_check2
        # WHERE opp_client <> supp_client
      
      flip_flop <- rename_client_position_change_check %>% 
        filter(opp_client != supp_client)
    
    # By distinct bill numbers 
      
    flip_flop %>% 
      distinct(bill_id, .keep_all = TRUE) %>% 
      View()
    
    flip_flop %>% 
      distinct(lobbyist_name, .keep_all = TRUE) %>% 
      View()
      
    # There are instances of lobbyists both supporting and opposing a bill. But it's unclear if that flip-flopping happened at the same time. 
        
      # If Bill ID is blank, that means they worked for an org before it formally became a bill. Need to eliminate. 
    
    flip_flop %>% 
      filter(!is.na(bill_id)) %>% 
      View()
    
      # Doing that made the number of rows from my SQL queries, 2,252, align with what R was showing. 
        # Before that query, R had artificially inflated matches with blanks in the bill ID column. 
    
        non_blank_flip_flop <- flip_flop %>% 
          filter(!is.na(bill_id)) 
          
        non_blank_flip_flop %>% 
          distinct(lobbyist_name, .keep_all = TRUE)
          
          # 74 distinct lobbyists who both opposed and supported a bill through their work. 
        
    # So what about when start date for opp is less than or equal to start date for supp? 
        
        non_blank_flip_flop %>% 
          filter(opp_position_start_date < supp_position_start_date)
        
        non_blank_flip_flop %>% 
          filter(opp_position_start_date > supp_position_start_date)
    
        # Maybe it needs to be less than or equal to the end date? Or ongoing?
          # less than or equal to for overlap?
        
          non_blank_flip_flop %>% 
            filter(opp_position_start_date <= supp_position_end_date) %>% 
            View()
       
        # Saw this within the results:     
          # Aponte Public Affairs, Inc. opposed 1232 for Colorado Association of Medical Equipment Services (CAMES) while supporting for Counties & Commissioners Acting Together (CCAT)
          # support position started after the oppose but ended at the same time 
        
          non_blank_flip_flop %>% 
            filter(opp_position_start_date < supp_position_end_date)
          
          non_blank_flip_flop %>% 
            filter(opp_position_start_date < supp_position_end_date & supp_position_start_date > opp_position_end_date) %>% 
            View()
      
          # supp start date less than opp end date
          
          non_blank_flip_flop %>% 
            filter(supp_position_start_date <= opp_position_end_date | opp_position_start_date <= supp_position_end_date) %>% 
            View()
        
            # I think the above query is on the right track, but it gives some false results because it gets messed up with the years
              # So I am going to pull out the years into a new column and make sure the years line up. 
  
              non_blank_flip_flop %>% write_csv("non_blank_flip_flop.csv", na = "")
              
              # I also need to worry about ongoing cases in there somehow. 
              
            # I am sure there is a way to pull out dates with lubridate in R, but I just wanted to pull them out in a way that I can trust quickly. 
              # =TEXT(M2, "YYYY")
              # Will reimport. 
              
              years_non_blank_flip_flop %>% 
                filter(supp_position_start_year == opp_position_start_year) %>% 
                filter(supp_position_start_date <= opp_position_end_date | opp_position_start_date <= supp_position_end_date) %>% 
                View()
                
                # Worked!
                  # I will need to do the inverse to get the other side of it. 
              
              years_non_blank_flip_flop %>% 
                filter(supp_position_start_year == opp_position_start_year) %>% 
                filter(opp_position_start_date <= supp_position_end_date | supp_position_start_date <= opp_position_end_date) %>% 
                View()
              
                  # Still 414 cases, which is a good sign! It means the OR part of the query is picking up everything it needs to 
              
                    # SQL verified
                      # CREATE TABLE same_years AS
                      # SELECT *
                      #   FROM years_non_blank_flip_flop
                      # WHERE supp_position_start_year = opp_position_start_year
              
                      # SELECT *
                      # FROM same_years
                      # WHERE supp_position_start_date <= opp_position_end_date
                      # OR opp_position_start_date <= supp_position_end_date
              
              
              years_non_blank_flip_flop %>% 
                filter(supp_position_start_year == opp_position_start_year) %>% 
                filter(supp_position_start_date <= opp_position_end_date | opp_position_start_date <= supp_position_end_date) %>% 
                distinct(lobbyist_name, .keep_all = TRUE) %>% 
                View()
              
                      # Worked, but didn't capture if a lobbyist does this multiple times. 
                        # Group by lobbyist and count:
              
              
              
                  # And ongoing cases too 
                    # The support or opposition started after the start/oppose and is still ongoing
                
                 years_non_blank_flip_flop %>% 
                   filter(supp_position_start_year == opp_position_start_year) %>%
                   filter((supp_position_start_date <= opp_position_end_date | opp_position_start_date <= supp_position_end_date) & (opp_position_end_date == "Ongoing"| supp_position_end_date == "Ongoing")) %>% 
                   View()
              
                 # Worked but there are some rows that shouldn't apply because of the timeline
                  # Tweaked: 
                 
                 years_non_blank_flip_flop %>% 
                   filter(supp_position_start_year == opp_position_start_year) %>%
                   filter((supp_position_start_date < opp_position_end_date | opp_position_start_date < supp_position_end_date) & (opp_position_end_date == "Ongoing"| supp_position_end_date == "Ongoing")) %>% 
                   View()
                  
                 # Adjust for "not if end date is before start date"
                 
                 years_non_blank_flip_flop %>% 
                   filter(supp_position_start_year == opp_position_start_year) %>%
                   filter((supp_position_start_date < opp_position_end_date | opp_position_start_date < supp_position_end_date) & (opp_position_end_date == "Ongoing"| supp_position_end_date == "Ongoing")) %>% 
                   filter(!(opp_position_end_date < supp_position_start_date)) %>% 
                   View()
                 
                  # That worked!!!! 56 additional columns
                    # Later found this gave false positives. See bottom of this notebook. 
                    # Does adding another condition change things?
                 
                       years_non_blank_flip_flop %>% 
                         filter(supp_position_start_year == opp_position_start_year) %>%
                         filter((supp_position_start_date < opp_position_end_date | opp_position_start_date < supp_position_end_date) & (opp_position_end_date == "Ongoing"| supp_position_end_date == "Ongoing")) %>% 
                         filter(!(opp_position_end_date < supp_position_start_date| supp_position_end_date < opp_position_start_date)) %>% 
                         View()
                 
                       # No it does not change it. 
                 
                       # SQL had 61 rows instead. 
                         # CREATE TABLE "same_years_ongoing" AS
                         # SELECT *
                         #   FROM same_years
                         # WHERE opp_position_end_date = "Ongoing" OR supp_position_end_date = "Ongoing"
                        
                          # but it looks like London Gates and Brock Herzberg are falsely in this grouping. Lobbying ended before the other gig started. 
                       
                        # Back to 56 rows. This fixed it:
                       
                           # SELECT *
                           #  FROM same_years_ongoing
                           # WHERE NOT opp_position_end_date < supp_position_start_date 
                           # OR supp_position_end_date < opp_position_start_date 
                        
                    # I think these rows may have already been included. In the SQL check I noticed a bunch of ongoing cases for Bowditch & Cassell Public Affairs.
                        # See work on bill_id 1028 for Fort Collins and Denver.
                        # I am glad I included it in a diff table and then pasted it together, but that could be why the full join wasn't working. The rows were already there. 
                       
       # Will do a full join to put them altogether
        
                      same_time <- years_non_blank_flip_flop %>% 
                        filter(supp_position_start_year == opp_position_start_year) %>% 
                        filter(opp_position_start_date <= supp_position_end_date | supp_position_start_date <= opp_position_end_date) 
                       
                      same_time_ongoing <- years_non_blank_flip_flop %>% 
                         filter(supp_position_start_year == opp_position_start_year) %>%
                         filter((supp_position_start_date < opp_position_end_date | opp_position_start_date < supp_position_end_date) & (opp_position_end_date == "Ongoing"| supp_position_end_date == "Ongoing")) %>% 
                         filter(!(opp_position_end_date < supp_position_start_date| supp_position_end_date < opp_position_start_date))
                         
                      same_time %>% full_join(same_time_ongoing) %>% 
                        View()
                      
                        # Worked, but too many rows at 702 rows. 
                      
                      full_join(same_time,same_time_ongoing,by="lobbyist_name")
                      
                      same_time %>% outer_join(same_time_ongoing)
                      
                        # That gives 1,182 rows. Makes no sense
                          # May need to export each as a CSV and then make my own larger CSV manually. V weird. 
                 
                            same_time %>% write_csv("same_time.csv", na = "")
                            
                            same_time_ongoing %>% write_csv("same_time_ongoing.csv", na = "")
                    
                 same_time_flip_flop <- same_time_flip_flop
                 
                    # That's what I did. Manually copied and pasted. 
                 
                    # I am curious about if there were unintended repeats between the two after checking my work in SQL
                 
                        same_time %>% anti_join(same_time_ongoing)
                        
                        # 358 rows in same_time not in same_time_ongoing
                        
                        same_time_ongoing %>% semi_join(same_time)
                 
                          # Semi-join returns all rows from x with a match in y. All 56 rows returned, so I think I may have injected repeat rows accidentally. 
                            # Inspo: https://dplyr.tidyverse.org/reference/filter-joins.html 
                        
            # Now I want to figure out how many times a lobbyist has done this (at the same time)
                #Format:
                 # all_unique_charges %>% 
                 # group_by(case_year) %>% 
                 #  summarize(race_charge_count = n())        
                 
                same_time_flip_flop %>% 
                  group_by(lobbyist_name) %>% 
                  summarize(count = n())   
                
                    # I think there are some false repeats. 
                  
                    same_time %>% 
                      group_by(lobbyist_name) %>% 
                      summarize(count = n())   
                
                      # Beasely being in data twice in same_time_flip_flop compared to same_time shows how I accidentally artificially njected repeats while trying to account for "ongoing" cases
                
                # distinct by opp_client
                
                  same_time_flip_flop %>% 
                    distinct(opp_client, .keep_all = TRUE) %>%
                    group_by(lobbyist_name) %>% 
                    summarize(count = n()) %>% 
                    arrange(desc(count)) 
                  
                  same_time %>% 
                    distinct(opp_client, .keep_all = TRUE) %>%
                    group_by(lobbyist_name) %>% 
                    summarize(count = n()) %>% 
                    arrange(desc(count)) 
                  
                  # 21 lobbyists 
                  
                  # distinct by supp_client 
                  
                  same_time %>% 
                    distinct(supp_client, .keep_all = TRUE) %>%
                    group_by(lobbyist_name) %>% 
                    summarize(count = n()) %>% 
                    arrange(desc(count)) 
                  
                    # 18 lobbyists this way .
                  
                  
                  same_time_flip_flop %>% 
                    group_by(lobbyist_name) %>% 
                    summarize(opp_client_count = n(), supp_client_count = n())
                  
                  # didn't work
                  
                  same_time_flip_flop %>% 
                    group_by(lobbyist_name, opp_client, supp_client) %>% 
                    summarize(count = n()) %>% 
                    View()
                  
                  same_time %>% 
                    group_by(lobbyist_name, opp_client, supp_client) %>% 
                    summarize(count = n()) %>% 
                    View()
                  
                  # worked!
                  
                  same_time_flip_flop %>% 
                    group_by(lobbyist_name, opp_client, supp_client, bill_id, opp_position_start_date, opp_position_end_date, supp_position_start_date, supp_position_end_date) %>% 
                    summarize(count = n()) %>% 
                    View()
                  
                  same_time %>% 
                    group_by(lobbyist_name, opp_client, supp_client, bill_id, opp_position_start_date, opp_position_end_date, supp_position_start_date, supp_position_end_date) %>% 
                    summarize(count = n()) %>% 
                    View()
                      
                  # Worked with more info. count column is still picking up all of these repeats though. Need to use other queries to flush out these repeating columns. 
                  
                  grouped_same_time_flip_flop <- same_time %>% 
                    group_by(lobbyist_name, opp_client, supp_client, bill_id, opp_position_start_date, opp_position_end_date, supp_position_start_date, supp_position_end_date) %>% 
                    summarize(count = n())
                  
                  select_grouped_same_time_flip_flop <- grouped_same_time_flip_flop %>% 
                    select(lobbyist, opp_lobbyist, supp_client, bill_id, opp_position_start_date, opp_position_end_date, supp_position_start_date, supp_position_end_date)
                  
                  # didn't work
                  
                  # I want to know how many times a lobbyist has double dipped at the same time and on how many bills. 
                  
                  grouped_same_time_flip_flop %>% 
                    group_by(lobbyist_name, bill_id) %>% 
                    summarize(count = n()) %>% 
                    View()
                  
                    # sorta worked. 
                      # shows all of the different times a lobbyist has flip-flopped for what bill. That is helpful.
                      # Some lobbyists flip-flopped multiple times on the same bill
                  
                        # Verified with SQL, 42 rows:
                         
                          # SELECT *
                          # FROM same_time_flip_flop
                          # GROUP BY lobbyist_name, bill_id
                          
                        # For the record, same rows as same_time_flip_flop too. Grouping did its job. 
                          # SELECT *
                          # FROM same_time_flip_flop
                          # GROUP BY lobbyist_name, bill_id
                  
                  grouped_same_time_flip_flop %>% 
                    group_by(lobbyist_name, opp_client, supp_client) %>% 
                    summarize(count = n())
                  
                  
                  grouped_2_same_time_flip_flop <- grouped_same_time_flip_flop %>% 
                        group_by(lobbyist_name, bill_id) %>% 
                        summarize(count = n())
                  
                  grouped_2_same_time_flip_flop %>% 
                    group_by(lobbyist_name) %>% 
                    summarize(count_flip_diff_bills = n()) %>% 
                    arrange(desc(count_flip_diff_bills))
                  
                      # That worked well!
                      # Is this also the partner within Mendez, Barkis and Associates  ?
                        # Mendez, Florangel M
                  
                  # Didn't capture as many possible combos as it should have. Should be 55 rows.
                  
                  grouped_3_same_time_flip_flop <- grouped_same_time_flip_flop %>% 
                    group_by(lobbyist_name, opp_client, supp_client) %>% 
                    summarize(count = n()) %>% 
                    View()
                  
                    # Vetted by SQL:
                      # Realized this when SQL didn't properly group everything off of just lobbyist_name and bill_id
                      # Back at 55 rows this way:
                  
                        # CREATE TABLE same_time_grouped_2 AS
                        # SELECT *
                        #  FROM same_time
                        # GROUP BY lobbyist_name, opp_client, supp_client
                     
                  flip_flop_clients_bills <- grouped_same_time_flip_flop %>% 
                    group_by(lobbyist_name, opp_client, supp_client) %>% 
                    summarize(count = n())
                  
                  flip_flop_clients_bills %>% write_csv("flip_flop_clients_bills.csv", na = "")
                     
                  grouped_3_same_time_flip_flop %>% 
                    group_by(lobbyist_name) %>% 
                    summarize(count_flip_diff_bills = n()) %>% 
                    arrange(desc(count_flip_diff_bills))
                  
                  grouped_same_time_flip_flop %>% 
                    group_by(lobbyist_name) %>% 
                    summarize(count_flip_diff_bills = n()) %>% 
                    arrange(desc(count_flip_diff_bills))
                  
                    # 27 lobbyists and policy groups worked both sides of a bill at the same time. 
                  
                          # 27 rows confirmed by SQL:
                  
                            # SELECT *
                            # FROM same_time
                            # GROUP BY lobbyist_name
                        
                  
                        # 8 did it for multiple bills. 
                          # Mendez, Barkis and Associates led the pack with 15 different bills. 
                    
                          # SQL confirmed. 
                          # SELECT lobbyist_name, count(lobbyist_name)
                          # FROM same_time_grouped_2
                          # GROUP BY lobbyist_name
                          # ORDER BY count(lobbyist_name) DESC
               
                  grouped_flip_flop_clients_bills <- grouped_same_time_flip_flop %>% 
                    group_by(lobbyist_name) %>% 
                    summarize(count_flip_diff_bills = n()) %>% 
                    arrange(desc(count_flip_diff_bills))
                  
                  
                  grouped_flip_flop_clients_bills %>% write_csv("grouped_flip_flop_clients_bills.csv", na = "")
                   
                  # Going through manually to match up bill ID with bill descriptions and I think R/SQL may have counted Mutch for two more than it should have. 
                    # Opposed for City of Fountain & supported for the Town of Monument for cataclytic converter theft
                      # This is another taxpayer-funded instance of double dipping.   
                    
                 # The date formulas gave some false-positives for same-time double dipping. I vetted them out with these formulas in Excel: =IF(AND(I3<O3,K3<Q3),"No","Yes") 
                  
                  
                  