# WSL Finishing

This file looks at the reliability of XG over/underperformance for players in the Women's Super League by calculating and plotting Cronbach's Alpha for different sample sizes. The process is the same that has been used to determine the [reliability](https://blogs.fangraphs.com/a-new-way-to-look-at-sample-size-math-supplement/) and ["stabilization points"](https://www.baseballprospectus.com/news/article/17659/baseball-therapy-its-a-small-sample-size-after-all/) for many baseball statistics. Data courtesy of StatsBomb from the StatsBombR package.

![wsl_cronbach](https://user-images.githubusercontent.com/64282166/175460687-cc8cd107-a766-4a46-9146-8592d5a9558e.png)

Generally, an alpha value of 0.7 is used as a threshold for reliability. An alpha value below 0.7 indicates that the measure is more affected by noise than signal, and is thus not a very reliable measure. This should just further illustrate how players very rarely over/underperform their expected goals with any consistency, even when they have a season's worth of shots. "Finishing skill," at least as measured by G-xG, is not something that can be reliably discerned without many seasons worth of shot data. Even then, it is difficult to say anything of a player's ability to outperform their expected goals.
