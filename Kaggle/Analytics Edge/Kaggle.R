#mine

train_unedited=read.csv("train2016.csv",na.strings = c("","NA"))
test=read.csv("test2016.csv",na.strings = c("","NA"))

table(test$YOB)
median(subset(test$YOB, test$YOB != 1900), na.rm=TRUE)

test$YOB[test$YOB == 1900 & !is.na(test$YOB)] <- 1984

table(train_unedited$YOB)
train <- subset(train_unedited, (train_unedited$YOB <= 2016 & train_unedited$YOB>=1900) | is.na(train_unedited$YOB))


train$YOB[train$YOB == 1901 & !is.na(train$YOB)] <- 1983
train$YOB[train$YOB == 1900 & !is.na(train$YOB)] <- 1983

train$YOB[train$YOB == 2011 & !is.na(train$YOB)] <- 1983
train$YOB[train$YOB == 2013 & !is.na(train$YOB)] <- 1983
Party<-train$Party
train$Party<-NULL
#Made equal number of columns since we do not have predictions in Test
data <- rbind(train, test)
# Creating AgeGroup
AgeGroup <- vector(mode="character", length=6955)
for(i in 1:6955){
  age <- 2016 - data$YOB[i]
  if(is.na(age)){
    AgeGroup[i] <- NA
  }
  else if(age < 18){
    AgeGroup[i] <- "Under18"
  }
  else if(age >= 18 & age < 25){
    AgeGroup[i] <- "18-24"
  }
  else if(age >= 25 & age < 35){
    AgeGroup[i] <- "25-34"
  }
  else if(age >= 35 & age < 45){
    AgeGroup[i] <- "35-44"
  }
  else if(age >= 45 & age < 55){
    AgeGroup[i] <- "45-54"
  }
  else if(age >= 55 & age < 65){
    AgeGroup[i] <- "55-64"
  }
  else if(age >= 65){
    AgeGroup[i] <- "Over65"
  }
}
rm(i, age)

AgeGroup <- factor(AgeGroup, c("Under18","18-24","25-34","35-44","45-54",
                               "55-64","Over65"), ordered = TRUE)

# I will now reorder Income and EducationLevel ordred factor variables.
data$Income <- factor(data$Income, levels=c("under $25,000",
                                            "$25,001 - $50,000",
                                            "$50,000 - $74,999",
                                            "$75,000 - $100,000",
                                            "$100,001 - $150,000",
                                            "over $150,000"),
                      ordered = TRUE)

data$EducationLevel <- factor(data$EducationLevel, 
                              levels=c("Current K-12","High School Diploma",
                                       "Associate's Degree",
                                       "Current Undergraduate",
                                       "Bachelor's Degree",
                                       "Master's Degree","Doctoral Degree"),
                              ordered = TRUE)

data$YOB <- NULL
USER_ID <- data$USER_ID
data <- cbind(USER_ID, AgeGroup, data[,2:106])
rm(USER_ID, AgeGroup)

train_Ordered <- data[1:5563,]
test_Ordered <- data[5564:6955,]
rm(data)

train_Ordered$Party<-Party

questions = grep("^Q",names(train_Ordered))
# loop over all the questions
for (i in questions) {# convert the ith question, note double brackets [[ notation ...
      train_Ordered[[i]] = factor(train_Ordered[[i]],exclude = NULL)
      }

Questions_test = grep("^Q",names(test_Ordered))

# loop over all the questions
for (i in questions) { # convert the ith question, note double brackets [[ notation ...
test_Ordered[[i]] = factor(test_Ordered[[i]],exclude = NULL)
}

imputed_train=read.csv("Imputed Train.csv")
imputed_test=read.csv("Imputed Test.csv")

questions = grep("^Q",names(imputed_train))
# loop over all the questions
for (i in questions) {# convert the ith question, note double brackets [[ notation ...
  imputed_train[[i]] = factor(imputed_train[[i]],exclude = NULL)
}

Questions_test = grep("^Q",names(imputed_test))

# loop over all the questions
for (i in Questions_test) { # convert the ith question, note double brackets [[ notation ...
  imputed_test[[i]] = factor(imputed_test[[i]],exclude = NULL)
}


LogModel=glm(Party~ AgeGroup + Gender + Income + HouseholdStatus + EducationLevel + Q109244 + Q115611 + 
               Q98197,data = imputed_train,family =binomial)

prediction=predict(LogModel,newdata= imputed_test,type = "response")

PredTestLabels = as.factor(ifelse(prediction<0.5, "Democrat", "Republican"))

MySubmission = data.frame(USER_ID = test$USER_ID, Predictions = PredTestLabels)

#write.csv(MySubmission, "SubmissionSimpleLog.csv", row.names=FALSE)

library(randomForest)
for(i in 1:107){levels(imputed_train[[i]])[is.na(levels(imputed_train[[i]]))] <- "NA"}
for(i in 1:106){levels(imputed_test[[i]])[is.na(levels(imputed_test[[i]]))] <- "NA"}


RFmodel=randomForest(Party~ AgeGroup + Gender + Income + HouseholdStatus + EducationLevel + Q109244 + Q115611
                     + Q98197,data = imputed_train,method="class")

rf_predict=predict(RFmodel,newdata = imputed_test,type = "prob")


MySubmission2 = data.frame(USER_ID = test$USER_ID, Predictions = rf_predict)

#write.csv(MySubmission2, "SubmissionRF.csv", row.names=FALSE)

#RF Model2

RFmodel=randomForest(Party~ AgeGroup + Gender + Income + HouseholdStatus + EducationLevel + Q109244 +
                       Q115611 + Q98197 + Q113181 + Q98869 + Q101163 + Q99480 + Q105840 + Q120379 + Q116881 
                     + Q106272 + Q120472 + Q115899 + Q102089 + Q110740 + Q119851 + Q121699 + Q115195 + Q106042 
                     + Q118232 + Q100680 + Q118892,data = imputed_train,method="class")

rf_predict=predict(RFmodel,newdata = imputed_test)

#Score 0.63932

#Top50 = 0.65848


