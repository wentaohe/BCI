function f = linear_reg(Xtrain, Ytrain)

f = pinv(Xtrain' * Xtrain) * (Xtrain' * Ytrain);

end