# Computational Biology: Using R for Data Parsing and Visualization 
# L. Ande Hesser

library(tidyverse)
#don't forget to set working directory 
rel_abundance <- read_csv("LAH_all.relative_abundance.noabx.csv")
abx_groups <- read_csv("abx_metadata_brief.csv")
clean_rel_abundance <- rel_abundance %>% gather(ID, Abundance, 
                                                E000823_1.8.periodic.relative_abundance: 
                                                  E035134_34.8.periodic.relative_abundance)

#make a new column that just has the individual's ID number, not the periodic/early sequencing info.
clean_rel_abundance <- clean_rel_abundance %>% mutate(ID_number = substr(ID, 1, 7))

#calculate an average abundance for each input for a single taxa AND single individual.
clean_rel_abundance_avg <- aggregate(select(clean_rel_abundance, "Abundance"), 
                                  by = list(clean_rel_abundance$Taxa, clean_rel_abundance$ID_number), FUN = mean)
colnames(clean_rel_abundance_avg) <- c("Taxa", "ID_number", "Avg_Abundance")
 
#rename this as its own tibble. We also don't care about viruses so remove those
Relative_abundance <- clean_rel_abundance_avg %>% filter(grepl("Viruses", Taxa) == FALSE) 
Rel_abundance_abx <- merge(Relative_abundance, abx_groups, by = 'ID_number')

#pull out summary abundances at the order level, we don't want family- or genus-level details. 
Order_abundance <- Relative_abundance %>% filter(grepl('f__', Taxa) == FALSE, grepl('o__', Taxa) == TRUE)
Order_abundance <-merge(Order_abundance, abx_groups, by = 'ID_number')
Order_abundance <- Order_abundance %>% mutate(Sqrt.Abundance = sqrt(Avg_Abundance))

#pull out only the family Lachnospiraceae 
Lachno_abundance <- Relative_abundance %>% filter(grepl('Lachnospiraceae', Taxa) == TRUE) 

#make shorter taxa names for prettier graph. The first 80 characters are the higher order Taxa, so remove those.
#also filter out the unnamed species because we don't care about those at this point
Lachno_abundance <- Lachno_abundance %>% mutate(Taxa_short = substr(Taxa, 80, nchar(Taxa))) %>% 
  filter(grepl("noname", Taxa_short) == FALSE)
Lachno_abundance <- merge(Lachno_abundance, abx_groups, by = 'ID_number')
Lachno_abundance <- Lachno_abundance %>% mutate(Sqrt.Abundance = sqrt(Avg_Abundance))

#make a heatmap of the order-level data 
Order_plot <- Order_abundance %>% ggplot()+ aes(x = ID_number, y = Taxa, fill = Sqrt.Abundance) +
  geom_tile(color = 'white') + scale_fill_gradient(low = "white", high = "steel blue") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 5)) + 
  xlab(" ") + ylab(" ") + ggtitle("Order Level Bacterial Abundance with Antibiotic Treatment") + 
  facet_grid(~ ABX_Treat, switch = "x", scales = "free_x", space = "free_x")
Order_plot 

#make a heatmap of the Lachnospiraceae data 
Lachno_plot<- Lachno_abundance %>% ggplot() + aes(x = ID_number, y = Taxa_short, fill = Sqrt.Abundance) + 
  geom_tile(color = 'white') + scale_fill_gradient(low = "white", high = "steel blue") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 5)) + 
  xlab(" ") + ylab(" ") + ggtitle("Lachnospiraceae species and antibiotic treatment") + 
  facet_grid(~ ABX_Treat, switch = "x", scales = "free_x", space = "free_x")
Lachno_plot
