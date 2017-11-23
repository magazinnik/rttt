rm(list=ls())
set.seed(123)

# libraries
library(MatchIt)
library(foreign)
library("Zelig")
library("scales")

# setwd("~/Desktop/Replication")

# load data
scores1 <- read.csv("Data/an1.csv", header=T)
scores2 <- read.csv("Data/an2.csv", header=T)
scores3 <- read.csv("Data/an3.csv", header=T)

# code policy types
b_standards <- c("standards_consortium", "standardsadopt", "common_assessments")
c_data <- c("data1", "data8")
d_teachers <- c("measuregrowth", "prepprogram", "pathwaysroutes", "evalsystem1", "evalsystem2", 
				"annualevals", "evalsprofdev", "evalsreward1", "evalsreward2", "evalstenure", "evalsfire")
e_lowach <- c("lowachieve_intervene")
f_innsch <- c("innovativeschoolsauth", "innovativeschoolsbuild", "innovativeschoolsnumber")

scores1$poltype <- NA
scores1$poltype[scores1$outcome %in% b_standards] <- "b_standards"
scores1$poltype[scores1$outcome %in% c_data] <- "c_data"
scores1$poltype[scores1$outcome %in% d_teachers] <- "d_teachers"
scores1$poltype[scores1$outcome %in% e_lowach] <- "e_lowach"
scores1$poltype[scores1$outcome %in% f_innsch] <- "f_innsch"
scores1$poltypeid <- as.numeric(as.factor(scores1$poltype))

scores2$poltype <- NA
scores2$poltype[scores2$outcome %in% b_standards] <- "b_standards"
scores2$poltype[scores2$outcome %in% c_data] <- "c_data"
scores2$poltype[scores2$outcome %in% d_teachers] <- "d_teachers"
scores2$poltype[scores2$outcome %in% e_lowach] <- "e_lowach"
scores2$poltype[scores2$outcome %in% f_innsch] <- "f_innsch"
scores2$poltypeid <- as.numeric(as.factor(scores2$poltype))

scores3$poltype <- NA
scores3$poltype[scores3$outcome %in% b_standards] <- "b_standards"
scores3$poltype[scores3$outcome %in% c_data] <- "c_data"
scores3$poltype[scores3$outcome %in% d_teachers] <- "d_teachers"
scores3$poltype[scores3$outcome %in% e_lowach] <- "e_lowach"
scores3$poltype[scores3$outcome %in% f_innsch] <- "f_innsch"
scores3$poltypeid <- as.numeric(as.factor(scores3$poltype))

################################################################
# Functions
################################################################

###############################################
# Covariate balance table
###############################################

baltable <- function(results, outfile) {
	n1 <- sum(results[[1]]$nn[2,])
	n2 <- sum(results[[2]]$nn[2,])
	n3 <- sum(results[[3]]$nn[2,])
	# run regressions for assessing balance
	ests.full <- list()
	ests.c1 <- list()
	ests.c2 <- list()
	stars.full <- list()
	stars.c1 <- list()
	stars.c2 <- list()
	for (i in 1:length(balvars)) {
		# full data
		m.data.full <- match.data(results[[1]])
		z.full <- eval(parse(text=paste0("zelig(", balvars[i], "~ treat, data = m.data.full, 
			  						model = 'ls', weights = 'weights')")))
		ests.full[[i]] <- summary(z.full$zelig.out$z.out[[1]])$coefficients[2,1]
		pval.full <- summary(z.full$zelig.out$z.out[[1]])$coefficients[2,4]
		stars.full[[i]] <- ifelse(pval.full < 0.01, "***", 
							ifelse(pval.full < 0.05, "**", ifelse(pval.full < 0.10, "*", " ")))
		# caliper 1
		m.data.c1 <- match.data(results[[2]])
		z.c1 <- eval(parse(text=paste0("zelig(", balvars[i], "~ treat, data = m.data.c1, 
			  						model = 'ls', weights = 'weights')")))
		ests.c1[[i]] <- summary(z.c1$zelig.out$z.out[[1]])$coefficients[2,1]
		pval.c1 <- summary(z.c1$zelig.out$z.out[[1]])$coefficients[2,4]
		stars.c1[[i]] <- ifelse(pval.c1 < 0.01, "***", 
							ifelse(pval.c1 < 0.05, "**", ifelse(pval.c1 < 0.10, "*", " ")))
		# caliper 2
		m.data.c2 <- match.data(results[[3]])
		z.c2 <- eval(parse(text=paste0("zelig(", balvars[i], "~ treat, data = m.data.c2, 
			  						model = 'ls', weights = 'weights')")))
		ests.c2[[i]] <- summary(z.c2$zelig.out$z.out[[1]])$coefficients[2,1]
		pval.c2 <- summary(z.c2$zelig.out$z.out[[1]])$coefficients[2,4]
		stars.c2[[i]] <- ifelse(pval.c2 < 0.01, "***", 
							ifelse(pval.c2 < 0.05, "**", ifelse(pval.c2 < 0.10, "*", " ")))
	}
	fileConn<-file(outfile)
	writeLines(c("{", "\n",
				 "\\def\\sym#1{\\ifmmode^{#1}\\else\\(^{#1}\\)\\fi}", "\n",
				 "\\begin{tabular}{l*{3}{C{2.2cm}C{2.2cm}C{2.2cm}}}", "\n",
				 "\\toprule", "\n",
				 "&  Full data & Cal=", cal1, " SD & Cal=", cal2, " SD \\\\", "\n",
				 "\\midrule", "\n",
				 "\\specialcell{Section score \\\\ \\; (\\% of possible points)} &", 
				 format(round(ests.full[[1]], digits=3),nsmall=3), stars.full[[1]], " & ", 
				 format(round(ests.c1[[1]], digits=3),nsmall=3), stars.c1[[1]], " & ",
				 format(round(ests.c2[[1]], digits=3),nsmall=3), stars.c2[[1]], " \\\\ ", "\n",
				 "\\specialcell{Past policy achievement \\\\ \\; (from application)} &", 
		 		 format(round(ests.full[[2]], digits=3),nsmall=3), stars.full[[2]], " & ", 
				 format(round(ests.c1[[2]], digits=3),nsmall=3), stars.c1[[2]], " & ",
				 format(round(ests.c2[[2]], digits=3),nsmall=3), stars.c2[[2]], " \\\\ ", "\n",
				 "\\specialcell{Past policy achievement \\\\ \\; (from legislative history, 2008)} &", 
				 format(round(ests.full[[3]], digits=3),nsmall=3), stars.full[[3]], " & ", 
				 format(round(ests.c1[[3]], digits=3),nsmall=3), stars.c1[[3]], " & ",
				 format(round(ests.c2[[3]], digits=3),nsmall=3), stars.c2[[3]], " \\\\ ", "\n",
				 "\\specialcell{Average policy achievement on \\\\ \\; non-RttT policies in same year \\\\ \\; (from legislative history)} &",
		 		 format(round(ests.full[[4]], digits=3),nsmall=3), stars.full[[4]], " & ", 
				 format(round(ests.c1[[4]], digits=3),nsmall=3), stars.c1[[4]], " & ",
				 format(round(ests.c2[[4]], digits=3),nsmall=3), stars.c2[[4]], " \\\\ ", "\n",
				 "\\midrule", "\n",
				 "N & ", n1, " & ", n2, " & ", n3, " \\\\", "\n",
				 "\\bottomrule", "\n",
				 "\\end{tabular}", "\n",
				 "}"), sep="", fileConn)
	close(fileConn)
}

###############################################
# ATT
###############################################

atttable <- function(results, outfile) {
	# number of observations
	n1 <- sum(results[[1]]$nn[2,])
	n2 <- sum(results[[2]]$nn[2,])
	n3 <- sum(results[[3]]$nn[2,])
	# full data
	m.data.full <- match.data(results[[1]])
	z.full <- zelig(Y ~ treat, data = m.data.full, model = 'ls', weights = 'weights')
	x0.out.full <- setx(z.full, treat=0)
	x1.out.full <- setx(z.full, treat=1)
	s.out.full <- sim(z.full, x = x0.out.full, x1 = x1.out.full)
	est.full <- summary(s.out.full$zelig.out$z.out[[1]])$coefficients[2,1]
	se.full <- summary(s.out.full$zelig.out$z.out[[1]])$coefficients[2,2]
	pval.full <- summary(s.out.full$zelig.out$z.out[[1]])$coefficients[2,4]
	star.full <- ifelse(pval.full < 0.01, "***", 
					ifelse(pval.full < 0.05, "**", ifelse(pval.full < 0.10, "*", " ")))
	# caliper 1 
	m.data.c1 <- match.data(results[[2]])
	z.c1 <- zelig(Y ~ treat, data = m.data.c1, model = 'ls', weights = 'weights')
	x0.out.c1 <- setx(z.c1, treat=0)
	x1.out.c1 <- setx(z.c1, treat=1)
	s.out.c1 <- sim(z.c1, x = x0.out.c1, x1 = x1.out.c1)
	est.c1 <- summary(s.out.c1$zelig.out$z.out[[1]])$coefficients[2,1]
	se.c1 <- summary(s.out.c1$zelig.out$z.out[[1]])$coefficients[2,2]
	pval.c1 <- summary(s.out.c1$zelig.out$z.out[[1]])$coefficients[2,4]
	star.c1 <- ifelse(pval.c1 < 0.01, "***", 
			   		ifelse(pval.c1 < 0.05, "**", ifelse(pval.c1 < 0.10, "*", " ")))
	# caliper 2
	m.data.c2 <- match.data(results[[3]])
	z.c2 <- zelig(Y ~ treat, data = m.data.c2, model = 'ls', weights = 'weights')
	x0.out.c2 <- setx(z.c2, treat=0)
	x1.out.c2 <- setx(z.c2, treat=1)
	s.out.c2 <- sim(z.c2, x = x0.out.c2, x1 = x1.out.c2)
	est.c2 <- summary(s.out.c2$zelig.out$z.out[[1]])$coefficients[2,1]
	se.c2 <- summary(s.out.c2$zelig.out$z.out[[1]])$coefficients[2,2]
	pval.c2 <- summary(s.out.c2$zelig.out$z.out[[1]])$coefficients[2,4]
	star.c2 <- ifelse(pval.c2 < 0.01, "***", 
					ifelse(pval.c2 < 0.05, "**", ifelse(pval.c2 < 0.10, "*", " ")))
	# write out table 
	fileConn<-file(outfile)
	writeLines(c("{", "\n",
				 "\\def\\sym#1{\\ifmmode^{#1}\\else\\(^{#1}\\)\\fi}", "\n",
				 "\\begin{tabular}{l*{6}{C{2.2cm}C{2.2cm}C{2.2cm}}}", "\n",
				 "\\toprule", "\n",
				 "&\\multicolumn{1}{c}{(1)} &\\multicolumn{1}{c}{(2)} &\\multicolumn{1}{c}{(3)} \\\\", "\n",
				 "& Full data & Cal=", cal1, " SD & Cal=", cal2, " SD \\\\", "\n",
				 "\\midrule", "\n",
				 "ATT &", format(round(est.full, digits=3), nsmall=3), star.full, " & ", 
				 format(round(est.c1, digits=3), nsmall=3), star.c1, " & ",
				 format(round(est.c2, digits=3), nsmall=3), star.c2, " \\\\ ", "\n",
				 "& ", "(", format(round(se.full, digits=3), nsmall=3), ") & ",
				 "(", format(round(se.c1, digits=3), nsmall=3), ") & ",
				 "(", format(round(se.c2, digits=3),nsmall=3), ") \\\\ ", "\n",
				 "\\midrule", "\n",
				 "N & ", n1, " & ", n2, " & ", n3, " \\\\", "\n",
				 "\\bottomrule", "\n",
				 "\\end{tabular}", "\n",
				 "}"), sep="", fileConn)
	close(fileConn)
}

###############################################
# QQ plots
###############################################

#results <- results1
#var <- "section_score"
qfun <- function(results, var, lim) {
	xi <- results[[1]]$X[var]
	xi$treat <- as.vector(results[[1]]$treat)
	matched.full <- results[[1]]$weights!=0
	matched.c1 <- results[[2]]$weights!=0
	matched.c2 <- results[[3]]$weights!=0
	xi.m1 <- xi[matched.full,]
	xi.m2 <- xi[matched.c1,]
	xi.m3 <- xi[matched.c2,]
	# make plots
	par(mfrow=c(1,4))
	main1 <- paste0("After matching, caliper=", cal1)
	main2 <- paste0("After matching, caliper=", cal2)
	qqplot(xi[xi$treat==0, var], xi[xi$treat==1, var], 
	   	   xlim = lim, ylim = lim,
	       xlab = "Control", ylab = "Treated",
	       main = "Before matching",
	       col = alpha("blue", 0.4), pch = 19)
	abline(0,1)
	qqplot(xi.m1[xi.m1$treat==0, var], xi.m1[xi.m1$treat==1, var], 
	   	   xlim = lim, ylim = lim,
	   	   xlab = "Control", ylab = "Treated",
	       main = "After matching, all matches",
	       col = alpha("blue", 0.4), pch = 19)
	abline(0,1)
	qqplot(xi.m2[xi.m2$treat==0, var], xi.m2[xi.m2$treat==1, var], 
	       xlim = lim, ylim = lim,
	       xlab = "Control", ylab = "Treated",
	       main = main1,
	       col = alpha("blue", 0.4), pch = 19)
	abline(0,1)
	qqplot(xi.m3[xi.m3$treat==0, var], xi.m3[xi.m3$treat==1, var], 
	   	   xlim = lim, ylim = lim,
	       xlab = "Control", ylab = "Treated",
	       main = main2,
	       col = alpha("blue", 0.4), pch = 19)
	abline(0,1)
}

################################################################
# Analysis
################################################################

X1 <- na.omit(scores1[, c("Y", "treat", "pctscoreA2i", "section_score", "year", "outcomeid", 
                          "poltypeid", "last_p", "control_2008", "control_mean", "statename")])
X2 <- na.omit(scores2[, c("Y", "treat", "pctscoreA2i", "section_score", "year", "outcomeid", 
						  "poltypeid", "last_p", "control_2008", "control_mean", "statename")])
X3 <- na.omit(scores3[, c("Y", "treat", "pctscoreA2i", "section_score", "year", "outcomeid", 
						  "poltypeid", "last_p", "control_2008", "control_mean", "statename")])

#################################################################
# main analysis: 
# exact match on year and policy domain
# nearest neighbor match on section score 
#################################################################

balvars <- c("section_score", "last_p", "control_2008", "control_mean")
matchform <- formula(treat ~ section_score)
exactvars <- c("poltypeid", "year")

# calipers
cal1 <- .1
cal2 <- .05

# initialize results lists
results7 <- list() # first comparison
results8 <- list() # second comparison
results9 <- list() # third comparison

## first comparison
# full data
results7[[1]] <- matchit(matchform,
				 exact = exactvars,
				 data = X1, 
				 method = "nearest")
# caliper 1
results7[[2]] <- matchit(matchform,
				 exact = exactvars,
				 data = X1, 
				 method = "nearest", 
				 caliper = cal1)
# caliper 2
results7[[3]] <- matchit(matchform,
				 exact = exactvars,
				 data = X1, 
				 method = "nearest", 
				 caliper = cal2)

## second comparison
# full data
results8[[1]] <- matchit(matchform,
				 exact = exactvars,
				 data = X2, 
				 method = "nearest")
# caliper 1
results8[[2]] <- matchit(matchform,
				 exact = exactvars,
				 data = X2, 
				 method = "nearest", 
				 caliper = cal1)
# caliper 2
results8[[3]] <- matchit(matchform,
				 exact = exactvars,
				 data = X2, 
				 method = "nearest", 
				 caliper = cal2)

## third comparison
# full data
results9[[1]] <- matchit(matchform,
				 exact = exactvars,
				 data = X3, 
				 method = "nearest")
# caliper 1
results9[[2]] <- matchit(matchform,
				 exact = exactvars,
				 data = X3, 
				 method = "nearest", 
				 caliper = cal1)
# caliper 2
results9[[3]] <- matchit(matchform,
				 exact = exactvars,
				 data = X3, 
				 method = "nearest", 
				 caliper = cal2)

##### create tables/figures
setwd("Output")

atttable(results = results7, outfile = "att_type_1.tex")
atttable(results = results8, outfile = "att_type_2.tex")
atttable(results = results9, outfile = "att_type_3.tex")

#### section score 
# first analysis
pdf(file = "plots_type_1.pdf", width = 16, height = 4)
qfun(results = results7, var = "section_score", lim = c(0,100))
dev.off()

# second analysis
pdf(file = "plots_type_2.pdf", width = 16, height = 4)
qfun(results = results8, var = "section_score", lim = c(0,100))
dev.off()

# third analysis
pdf(file = "plots_type_3.pdf", width = 16, height = 4)
qfun(results = results9, var = "section_score", lim = c(0,100))
dev.off()