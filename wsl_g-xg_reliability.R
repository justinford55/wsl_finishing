library(extrafont)
loadfonts(device = "win")
library(tidyverse)
library(StatsBombR)


comps <- FreeCompetitions()

wsl <- comps %>%
  filter(competition_id == 37)

matches <- FreeMatches(wsl)

df <- StatsBombFreeEvents(matches)

df <- allclean(df)

columns <- names(df)

# clean is 443305 by 183

shots <- df %>%
  filter(type.name == "Shot") %>%
  select(id, period, timestamp, type.name, team.id, player.id, player.name, 
         shot.statsbomb_xg, shot.outcome.name, match_id, season_id) %>%
  mutate(is_goal = ifelse(shot.outcome.name == "Goal", 1, 0))

rm(df)
gc()

# construct a matrix
# each row is a player, each column is a randomly selected shot from each player's sample
# the values will indicate G-XG

# function for alpha
alpha <- function(k, item_var, player_totals) {
  return((k/(k-1)) * (1 - sum(item_var)/var(player_totals)))
}

alphas <- c()
ks <- seq(5, 50, by = 2)

# g - xg
shots <- shots %>%
  mutate(g_minus_xg = is_goal - shot.statsbomb_xg)

set.seed(111)

for (k in ks) {
  
  # filters for players that meet the shot threshold
  players_with_min_shots <- shots %>%
    group_by(player.id, season_id) %>%
    summarize(n_shots = n()) %>%
    filter(n_shots >= k) %>%
    mutate(player_season_id = paste(player.id, season_id, sep = "_"))
  
  # this is the list of player seasons that meet the threshold
  players <- unique(players_with_min_shots$player_season_id)
  
  # initialize the "matrix"
  data <- c()
  
  # for each player, I want a vector of K
  # the vector contains randomly selected g-xg values from the data
  # each vector then becomes a row of K columns in a matrix of N rows
  for (player in players) {
    
    # looking only at this player and season, gets all shots
    player_shots <- shots %>%
      filter(player.id == gsub("_.*$", "", player) &
               season_id == gsub("^.*_", "", player))
    
    # randomly selects K indices
    shot_indices <- sample(seq_len(nrow(player_shots)), k)
    
    # gets the values at the random indices
    player_row <- player_shots[shot_indices,]$g_minus_xg
    
    # add the row of K g-xg for that player-season to the rest of the data
    data <- rbind(data, player_row)
  }
  
  # initializing a vector of length K which will store the variance of each "column" of the "matrix"
  item_var <- rep(NA, k)
  
  # calculcating and storing the item variances
  for (i in seq_len(k)) {
    item_var[i] <- var(data[,i])
  }
  
  # total g-xg for each player-season row
  player_totals <- rowSums(data)
  
  # calculates and stores alpha
  alphas <- append(alphas, alpha(k, item_var, player_totals))
  
}

alpha_table <- tibble(alpha = alphas, k = ks)

alpha_table %>%
  ggplot(aes(k, alpha)) +
  geom_line() +
  theme_SB() +
  labs(
    title = "Reliability of G-xG by Player/Season",
    x = "Shots",
    y = "Alpha"
  )

################################################################################
# instead of splitting by player and season,
# I'm only splitting by player here

alphas <- c()
ks <- seq(5, 100, by = 5)

set.seed(111)

for (k in ks) {
  
  # filters for players that meet the shot threshold
  players_with_min_shots <- shots %>%
    group_by(player.id) %>%
    summarize(n_shots = n()) %>%
    filter(n_shots >= k)
  
  # this is the list of player seasons that meet the threshold
  players <- unique(players_with_min_shots$player.id)
  
  # initialize the "matrix"
  data <- c()
  
  # for each player, I want a vector of K
  # the vector contains randomly selected g-xg values from the data
  # each vector then becomes a row of K columns in a matrix of N rows
  for (player in players) {
    
    # looking only at this player and season, gets all shots
    player_shots <- shots %>%
      filter(player.id == player)
    
    # randomly selects K indices
    shot_indices <- sample(seq_len(nrow(player_shots)), k)
    
    # gets the values at the random indices
    player_row <- player_shots[shot_indices,]$g_minus_xg
    
    # add the row of K g-xg for that player-season to the rest of the data
    data <- rbind(data, player_row)
  }
  
  # initializing a vector of length K which will store the variance of each "column" of the "matrix"
  item_var <- rep(NA, k)
  
  # calculcating and storing the item variances
  for (i in seq_len(k)) {
    item_var[i] <- var(data[,i])
  }
  
  # total g-xg for each player-season row
  player_totals <- rowSums(data)
  
  # calculates and stores alpha
  alphas <- append(alphas, alpha(k, item_var, player_totals))
  
}

alpha_table <- tibble(alpha = alphas, k = ks)

alpha_table %>%
  ggplot(aes(k, alpha)) +
  geom_line() +
  theme_SB() +
  labs(
    title = "Reliability of G-xG by Player",
    x = "Shots",
    y = "Alpha"
  )

