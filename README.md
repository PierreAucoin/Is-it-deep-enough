# Is-it-deep-enough
Determining how far a ball has to travel for a sacrifice fly to successfully score the runner from
third base has been a question for many baseball fans. In this paper, I create a sac fly line that
gives fans a perspective on how far a ball has to travel for a successful sac fly. A logistic
regression model is created to determine the probability of a successful sac fly based on the
fielder’s throwing ability, the distance the ball travels and the pace per ninety feet of the runner
on third. The fielder’s throwing ability is quantified by a novel metric I developed called sniper,
which provides a value that combines a fielder’s throwing strength alongside their accuracy in
throws to home plate. With this model, it is now possible to compute the distance the ball must
travel to have a specific probability of the corresponding sac fly being successful. A Shiny app is
used to demonstrate how this can be displayed on the jumbotron during a baseball game to
provide fans valuable information regarding the success of a potential sac fly. This project was an honourable mention for SMT Data Competition in 2026
