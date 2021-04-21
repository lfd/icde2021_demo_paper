library(ggplot2)
library(stringr)
library(dplyr)

## TODO: Document meaning of evaluationparameters (and explain
## importance thereof)
lab <- "docker"
sf <- "0.1"

## Nothing to configure below her
## Measured values are in nanoseconds (10^9). us: 10^-6, ms: 10^-3
USEC.PER.NSEC <- (1000)
MSEC.PER.NSEC <- (1000*1000)
SEC.PER.NSEC <- (1000*1000*1000)

colours <- c('#15a521', '#d105d1', '#007ee3',
             '#81a6ff', '#25798c', '#f4c442')

########
## Prepare base data frame from measured values
dirs <- str_c("../results/res_SF-", sf, "_scenario-", c("polite", "impolite"), "_", lab)

res <- do.call(rbind, lapply(dirs, function(dir) {
     dat <- read.table(str_c(dir, "/results.csv"), header=FALSE)
     colnames(dat) <- c("query", "id", "time", "latency")
     dat$dir <- dir
     return(dat)
}))

res.sub <- res[res$query %in% c(6,8,15,21),]

########
## Infer dataset for queries per time throughput, resolved by TPC-H query
res.tp <- res %>% group_by(query, dir) %>% summarise(queries=length(time)+1, duration=max(time),
                                                     min=min(latency), max=max(latency),
                                                     avg=mean(latency),  med=median(latency))
res.tp$query <- factor(res.tp$query, levels=sort(unique(res.tp$query)), labels=str_c("Q", sort(unique(res.tp$query))))

########
## Create visualisations

gen.latency.plot <- function(dat) {
    g <- ggplot(dat, aes(x=time/SEC.PER.NSEC, y=latency/MSEC.PER.NSEC, colour=dir)) + geom_point(size=0.5) +
        geom_line() + xlab("Time [s]") + ylab("Latency [ms]") + theme_bw() +
        facet_wrap(query~., scales="free") +
        theme(legend.position="top") + scale_colour_discrete("Mindset", labels=c("Impolite", "Polite"))
    return(g)
}

labels.dir <- c("Polite", "Impolite")
names(labels.dir) <- dirs
gen.throughput.plot <- function(dat) {
    g <- ggplot(dat, aes(x=query, y=1/avg*SEC.PER.NSEC, fill=dir)) + geom_bar(stat="identity", position="dodge") +
        xlab("TPC-H Query") + ylab("Throughput [Q/s]") + theme_bw() +
        facet_grid(dir~., labeller=labeller(dir=labels.dir)) +
        geom_errorbar(aes(ymin=1/min*SEC.PER.NSEC, ymax=1/max*SEC.PER.NSEC), width=0.4) +
        theme(legend.position="none") + scale_fill_discrete("Mindset", labels=c("Impolite", "Polite"))
    return(g)
}

##########
## Interactive staging area
##gen.latency.plot(res.sub)
##gen.throughput.plot(res.tp)
