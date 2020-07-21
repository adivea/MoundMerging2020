### Analyze size differences - script copied from previous work on LGV mounds!

### Mounds Size Assessment 
## inspired by Laursen's study of the Bahrain cemetery

# categorical sizes?


## Read in data on Mounds in Kaz

#Get mound sizes
abmounds %>% 
  select(Trap, TopoID.x, Type, Length, Height.x, Height.y)


head(abmounds$Height.y)
head(abmounds)

m2010_diam <- as.numeric(abmounds$Length)
m2010_h <- as.numeric(abmounds$Height.x)

m2009_diam <- as.numeric(mnd2009$Length)
m2009_h <-as.numeric(mnd2009$Height)

m2017_diam <- mnd2017$DiameterMax
m2017_h <- as.numeric(mnd2017$HeightMax)

m2018_diam <- mnd2018$DiameterMax
m2018_h <- mnd2018$HeightMax


length(m2010_h)
################  MOUND HEIGHT

# 5e Histogram unconstrained
par(mfrow=c(2,2))

hist(m2009_h,xlab = "Mound height (m)", ylab = "Count", col="black", breaks=30, main = "2009 Elhovo mounds", border="white",las=1, axes=F)
axis(1, las=1, at=c(0,1,2,5,10,20))
axis(2, las=1, at=c(0,5, 10, 25, 50))

hist(m2010_h,xlab = "Mound height (m)", ylab = "Count", col="black", breaks=30, main = "2010 LGV mounds", border="white",las=1, axes=F)
axis(1, las=1, at=c(0,1,2,5,10,20))
axis(2, las=1, at=c(0,5, 10, 25, 50))

hist(m2017_h,xlab = "Mound height (m)", ylab = "Count", col="black", breaks=30, main = "2017 Elenovo mounds", border="white",las=1, axes=F)
axis(1, las=1, at=c(0,1,2,5,10,20))
axis(2, las=1, at=c(0,5, 10, 25, 50))

hist(m2018_h,xlab = "Mound height (m)", ylab = "Count", col="black", breaks=30, main = "2018 Bolyarovo mounds", border="white",las=1, axes=F)
axis(1, las=1, at=c(0,1,2,5,10,20))
axis(2, las=1, at=c(0,5, 10, 25, 50))



################BOXPLOTS
# Boxplot of sizes
?pdf
boxplot(m2010_diam~m2010_h, xlab = "Height(m)", ylab="Diameter(m)", main = "LGV mounds (406) total)")
pdf("./output_figures/LGVSizeBoxplot.pdf")
dev.off()

# Plot of height over diameter
plot(m2010_diam~m2010_h, xlab = "Height(m)", ylab="Diameter(m)", main = "LGV mounds (406) total)")

# CONTINUE HERE



##### Labelling Points in a Scatter Plot
##### By Eric Cai - The Chemical Statistician
#https://www.r-bloggers.com/adding-labels-to-points-in-a-scatter-plot-in-r/


# Then, let’s use the text() function to add the text labels to the data.  
# It has to be nested within the with() function, because, unlike plot(), “data” is not a valid option for text().

str(mounds)
names <- mounds$BG.Name
names
plot(diam~h, xlab = "Height(m)", ylab="Diameter(m)", main = "Kazanlak burial mounds (773 total)", data = mounds)  # pch=2 is an empty triangle
with(mounds,text(diam~h,labels = names,pos = 2))

# http://www.statmethods.net/advgraphs/parameters.html

#The “pos” option specifies the position of the text relative to the point.  I have chosen to use “4″ because I want the text to be to the right of the point.
# 1 = below
# 2 = left
# 3 = above
# 4 = right
