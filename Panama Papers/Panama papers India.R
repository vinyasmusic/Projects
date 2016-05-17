library(stringr)
main_addresses=read.csv("Addresses.csv")
indian_addresses=subset(main_addresses,main_addresses$countries=="India")
indian_addresses$address<- gsub('[*/,.;#@`~!-]', ' ', indian_addresses$address)
write.csv(indian_addresses,file="Indian Addresses.csv")

#load up the ggmap library

library(ggmap)
# get the input data
infile <- "Indian Addresses"
data <- read.csv("Indian Addresses.csv")

# get the address list, and append country name to the end to increase accuracy 
# (change or remove this if your address already include a country etc.)

addresses = data$address
#addresses = paste0(addresses, ", India")

#If error, missing column name is the likely problem

#Define a function that will process googles server responses for us.

getGeoDetails <- function(address){   
  #use the gecode function to query google servers
  geo_reply = geocode(address, output='all', messaging=TRUE, override_limit=TRUE)
  #now extract the bits that we need from the returned list
  answer <- data.frame(lat=NA, long=NA, accuracy=NA, formatted_address=NA, address_type=NA, status=NA)
  answer$status <- geo_reply$status
  
  #if we are over the query limit - want to pause for an hour
  while(geo_reply$status == "OVER_QUERY_LIMIT"){
    print("OVER QUERY LIMIT - Pausing for 1 hour at:") 
    time <- Sys.time()
    print(as.character(time))
    Sys.sleep(60*60)
    geo_reply = geocode(address, output='all', messaging=TRUE, override_limit=TRUE)
    answer$status <- geo_reply$status
  }
  
  #return Na's if we didn't get a match:
  if (geo_reply$status != "OK"){
    return(answer)
  }   
  else # extract what we need from the Google server reply into a dataframe:
    answer$lat <- geo_reply$results[[1]]$geometry$location$lat
  answer$long <- geo_reply$results[[1]]$geometry$location$lng   
  if (length(geo_reply$results[[1]]$types) > 0){
    answer$accuracy <- geo_reply$results[[1]]$types[[1]]
  }
  answer$address_type <- paste(geo_reply$results[[1]]$types, collapse=',')
  answer$formatted_address <- geo_reply$results[[1]]$formatted_address
  
  return(answer)
}

#initialise a dataframe to hold the results
geocoded <- data.frame()

#Find out where to start in the address list (if the script was interrupted before):

startindex <- 1
#if a temp file exists - load it up and count the rows!
tempfilename <- paste0(infile, '_temp_geocoded.rds')
if (file.exists(tempfilename)){
  if (nrow(geocoded)<nrow(indian_addresses))
  {
    print("Found temp file - resuming from index:")
    geocoded <- readRDS(tempfilename)
    startindex <- nrow(geocoded)
    print(startindex)
  }
  else {startindex<-nrow(geocoded)}
  ifelse (nrow(geocoded)!=nrow(data),geocoded<-geocoded[-2,],geocoded<-geocoded)
  ifelse (nrow(geocoded)>nrow(data),geocoded<-geocoded[-nrow(geocoded),],geocoded<-geocoded)
}

#Start the geocoding process - address by address. geocode() function takes care of query speed limit.

for (ii in seq(startindex, length(addresses))){
  print(paste("Working on index", ii, "of", length(addresses)))
  #query the google geocoder - this will pause here if we are over the limit.
  result = getGeoDetails(str_replace_all(as.character(addresses[ii]),"([*~!@#$?./])", " ")  )
  print(result$status)     
  result$index <- ii
  #append the answer to the results file.
  geocoded <- rbind(geocoded, result)
  #save temporary results as we are going along
  saveRDS(geocoded, tempfilename)
}

#Removing extra rows
#Find out why this is happening
ifelse (nrow(geocoded)!=nrow(data),geocoded<-geocoded[-2,],geocoded<-geocoded)
ifelse (nrow(geocoded)>nrow(data),geocoded<-geocoded[-nrow(geocoded),],geocoded<-geocoded)

#Adding the lat long to main data

data$lat <- geocoded$lat
data$long <- geocoded$long
data$accuracy <- geocoded$accuracy

#Write the data to file

write.csv(data,file="Addresses_geocoded.csv")
addressplot<-na.omit(as.data.frame(cbind(data$lat,data$long)))
colnames(addressplot)<-c("lat","long")

#Plot the data on map

mapgilbert <- get_map(location = c(lon = mean(addressplot$long), lat = mean(addressplot$lat)), zoom = 4,maptype = "satellite", scale = 2)

ggmap(mapgilbert) +
geom_point(data = addressplot, aes(x = long, y = lat, fill = "red", alpha = 0.8), size = 2, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE)

