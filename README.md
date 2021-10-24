# Irish Covidtracker statistics

This repository contains a set of in-app JSON statistics files containing
counts and other information about the Irish Covidtracker GAEN app.

The JSON files here are those downloaded each day as part of our
[TEK-transparency](https://github.com/sftcd/tek_transparency/) work.  The
specific files are from our first hourly run after midnight each day between
2020-10-08 and 2021-04-08 so represent six months of data.

There is also a [CSV file](ie-stats.csv) that is a slightly cleaned up version of the one
produced from those JSON files using this [script](ie-stats.sh).  

In April 2021 we published a short [report](https://down.dsg.cs.tcd.ie/tact/ie-stats.pdf)
describing this. At that time the Irish health authority (the [HSE](https://hse.ie))
numbers showed that 75% fewer than expected keys had been uploaded by the
Irish Covidtracker app. For the most recent 30 days (at that time) the
shortfall was 85%. 

In October 2021 we updated this repo with an additional six months of
data, at which point the shortfall over the entire deployment is now
at 82% (was 75%) and for the most recent 30 days, 94% (was 85%). That
is a further deterioration from what was a very poor position.

We also updated the figures from our earlier [report](https://down.dsg.cs.tcd.ie/tact/ie-stats.pdf)
showing the [cases](cases.png), [expected versus actual uploads](exp-vs-actual.png) and
the daily [shortfall](shortfall.png).

