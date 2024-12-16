library(lme4)

fake_data <- data.frame(factor = gl(2, 3, labels = letters[1:2]),
           resp = .3)

model.matrix(resp ~ 1, fake_data)

model.matrix(resp ~ 1 + factor, fake_data)

## 3 levels


fake_data <- data.frame(factor = gl(3, 3, labels = letters[1:3]),
           resp = .3)


model.matrix(resp ~ 1 + factor, fake_data)
