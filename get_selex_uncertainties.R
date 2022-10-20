if(FALSE){
  # WARNING: this file written in 2013 and may not work with current
  #          example model files
  
  # save working directory
  oldwd <- getwd()

  # directory with model files
  dir <- "C:/ss/selex/selex_length_example"
  #dir <- "C:/ss/selex/selex_age_example"

  # make backup of starter file prior to making changes to it
  file.copy(file.path(dir,'starter.ss'),file.path(dir,'starter_backup.ss'))
  # read starter file
  new.starter <- starter <- SS_readstarter(file.path(dir,'starter.ss'))

  # change starter so that it reads from .par file
  new.starter$init_values_src <- 1
  # change starter so that it looks for a modified control file
  new.starter$ctlfile <- "ctl_modified.ss"
  # write changed starter to the file
  SS_writestarter(new.starter, dir=dir, overwrite=TRUE)

  # get info on number of fleets from data file
  dat <- SS_readdat(file.path(dir,starter$datfile))
  Ntypes <- dat$Nfleet
  # read control file as lines
  new.ctl <- ctl <- readLines(file.path(dir,starter$ctlfile))
  specs.row <- ctl[grep("Selectivity:", ctl, fixed = TRUE)]

  # change working directory (convenient for running models)
  setwd(dir)
  # loop over fleet types
  for(itype in 1:Ntypes){
    # create new row to specify which fleets have selectivity uncertainty calculated
    new.specs.row <- paste(itype,substring(specs.row,3))
    new.ctl[grep("Selectivity:", new.ctl, fixed = TRUE)] <- new.specs.row
    # write modified control file
    writeLines(new.ctl, file.path(dir,"ctl_modified.ss"))
    # run model
    system("ss -phase 10")
    # save output files
    file.copy("Report.sso",paste("Report_",itype,".sso",sep=""),overwrite=TRUE)
    file.copy("covar.sso",paste("covar_",itype,".sso",sep=""),overwrite=TRUE)
  }

  # restore starter file
  file.copy(file.path(dir,'starter_backup.ss'),file.path(dir,'starter.ss'),overwrite=TRUE)
  # restore working directory
  setwd(oldwd)
}

# read model output
dir1 <- "C:/SS/selex/selex_length_example"
dir2 <- "C:/SS/selex/selex_age_example"
Ntypes1 <- 5
Ntypes2 <- 6

models1 <- SSgetoutput(keyvec=1:Ntypes1,dirvec=dir1,underscore=TRUE,getcomp=FALSE,getcovar=FALSE)
models2 <- SSgetoutput(keyvec=1:Ntypes2,dirvec=dir2,underscore=TRUE,getcomp=FALSE,getcovar=FALSE)

png('c:/SS/selex/figs/selex_length_uncertainty.png',width=8,height=6,res=300,units='in')
par(mfrow=c(3,2), mar = c(3,2,3,1), oma = c(2,2,0,0))
for(i in 1:Ntypes1) SSplotSelex(models1[[i]],subplot=22,sexes=1)
mtext("Age", side = 1, line = 0, outer = TRUE)
mtext("Selectivity", side = 2, line = 0.5, outer = TRUE)
dev.off()

png('c:/SS/selex/figs/selex_age_uncertainty.png',width=8,height=6,res=300,units='in')
par(mfrow=c(3,2), mar = c(3,2,3,1), oma = c(2,2,0,0))
for(i in 1:Ntypes2) SSplotSelex(models2[[i]],subplot=22,sexes=1)
mtext("Age", side = 1, line = 0, outer = TRUE)
mtext("Selectivity", side = 2, line = 0.5, outer = TRUE)
dev.off()


png('c:/SS/selex/figs/selex_shapes.png',
    width=10, height=5, res=300, units='in', pointsize = 10)
par(mfrow=c(1,2))
SSplotSelex(models1[[1]], subplot=1, showmain = FALSE)
title(main = "selex_length_example")
SSplotSelex(models2[[1]], subplot=2, showmain = FALSE, agefactor = "Asel")
title(main = "selex_age_example")
dev.off()
