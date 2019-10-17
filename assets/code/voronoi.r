bisector <- function (P1, P2) {
	delta <- P2 - P1
	mid <- (P1 + P2) / 2.0
	result <- c(-delta[1] / delta[2], (t(delta) %*% mid) / delta[2])
}

plotb <- function (P1, P2, col = "black", x = c(-10, 10)) {
	b <- bisector(P1, P2)
	y <- b[1] * x + b[2]
	lines(x, y, col = col)
}

plotbh <- function (P1, P2, col = "black", x = seq(-10, 10, by = 0.1)) {
	b <- bisector(P1, P2)
	y <- b[1] * x + b[2]
	dx <- x - P2[1]
	dy <- y - P2[2]
	y <- y + sqrt(dx * dx + dy * dy)
	lines(x, y, col=col)
}

plotl <- function (P, l, col = "black") {
	text(t(P), l, col = col)
}

plotp <- function (P, l, col = "black", offset = c(0.4, 0)) {
	points(t(P), col = col)
	plotl(P + offset, l, col = col)
}

lineval <- function(x, line) {
	result <- (line[3] - line[1] * x) / line[2]
}

psb <- function(P1, n1, P2, n2, x, color = "black") {
	b <- bisector(P1, P2)
	y <- b[2] + b[1] * x
	print(sprintf("%02f * x + %02f", b[1], b[2]))
	offset <- c(0.4, 0)
	lines(x, y, col=color)
	points(t(P1))
	text(t(P1 + offset), n1)
	points(t(P2))
	text(t(P2 + offset), n2)
}

dist <- function (P1, P2) {
	return <- sqrt(sum((P2 - P1)^2))
}

psbh <- function (P1, n1, P2, n2, x, color= "black") {
	b <- bisector(P1, P2)
	y <- b[2] + b[1] * x
	dx <- x - P2[1]
	dy <- y - P2[2]
	y <- y + sqrt(dx * dx + dy * dy)
	offset <- c(0.4, -0.4)
	lines(x, y, col=color)
	points(t(P1))
	text(t(P1 + offset), n1)
	points(t(P2))
	text(t(P2 + offset), n2)
}

xlabel <- function (P1, P2, P3, label) {
	b1 <- bisector(P1, P2)
	b2 <- bisector(P2, P3)
	xx <- (b1[2] - b2[2]) / (b1[1] - b2[1])
	xy <- b1[1] * xx + b1[2]
	text(xx, xy - 0.4, label)
}

crossb <- function (P1, P2, P3) {
	b1 <- bisector(P1, P2)
	b2 <- bisector(P2, P3)
	xx <- (b2[2] - b1[2]) / (b1[1] - b2[1])
	xy <- b1[1] * xx + b1[2]
	return <- c(xx, xy)
}

crossbh <- function (P1, P2, P3) {
	cross <- crossb(P1, P2, P3)
	return <- c(cross[1], cross[2] + dist(cross, P3))
}

wholeplot <- function (A, B, X, Y, Z, plotter = plotb, offset = c(0.4, 0)) {
	plotter(A, B)
	plotter(A, X, col = "blue")
	plotter(B, X, col = "red")
	plotter(A, Y, col = "blue")
	plotter(B, Y, col = "red")
	plotter(A, Z, col = "blue")
	plotter(B, Z, col = "red")
	
	plotp(A, "A", col = "blue", offset = offset)
	plotp(B, "B", col = "red", offset = offset)
	plotp(X, "X", offset = offset)
	plotp(Y, "Y", offset = offset)
	plotp(Z, "Z", offset = offset)
}

crossplot <- function (A, B, X, Y, Z) {	
	offset <- c(0, -0.4)
	plotl(crossb(A, B, X) + offset, "X'")
	plotl(crossb(A, B, Y) + offset, "Y'")
	plotl(crossb(A, B, Z) + offset, "Z'")
}

x <- seq(-10, 10, by = 0.1)
A <- c(3, 0)
B <- c(4, 1)
X <- c(0, 6.5)
Y <- c(0, 9)
Z <- c(0, 11.5)

par(mfrow=c(1,1))

plot('x', 'y', xlab='', ylab='', type="n", ylim=c(-1, 12), xlim=c(-5, 5), asp=1)
wholeplot(A, B, X, Y, Z)
crossplot(A, B, X, Y, Z)
lines(c(0, 0), c(-0.5, 12), lty="dotted")

plot('x', 'y', xlab='', ylab='', type="n", ylim=c(-1, 12), xlim=c(-5, 5), asp=1)
wholeplot(A, B, X, Y, Z, plotter = plotbh, offset = c(0.3, 0.3))
plotl(crossbh(A, B, X) + c(0.4, -0.2), "X'")
plotl(crossbh(A, B, Y) + c(-0.3, -0.4), "Y'")
plotl(crossbh(A, B, Z) + c(-0.2, -0.3), "Z'")
lines(c(0, 0), c(-0.5, 12), lty="dotted")

plot('x', 'y', xlab='', ylab='', type="n", ylim=c(-1, 12), xlim=c(-5, 5), asp=1)
P1 <- c(-1.5, 0)
P2 <- c(-0.5, 5)
plotbh(P1, P2)
plotp(P1, "A", col = "blue", offset = offset)
plotp(P2, "B", col = "red", offset = offset)
lines(c(-6, 6), c(7, 7), lty="dotted")
text(-5, 6.5, "R* of A", col="blue")
text(0, 6.5, "R* of B", col="red")
text(5, 6.5, "R* of A", col="blue")

