# Create state list
state_ls = setNames(as.list(as.character(usdata::state_stats$abbr)), usdata::state_stats$state)
state_ls[["All States"]] = "all_states"
# Create org_ls
org_ls <- as.list(sprintf("501(c)(%s)", c(1:10, "d", "e", "f", "k")))
org_ls[["All Organizations"]] = "All Organizations"
setNames(org_ls, unlist(org_ls))
