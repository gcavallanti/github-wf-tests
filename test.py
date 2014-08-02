#! /usr/bin/env python
# -*- coding: latin-1 -*-
import random, math, sys, time

def signum(x): return cmp(x, -x)

def dotProduct(w, x): 
    return reduce(lambda x, y: x + y, [w[i] * x[i] for i in range(len(w))], 0)

def norm(v): return math.sqrt(reduce(lambda x, y: x + y**2, v, 0))

def sub(v, w): return [v[i] - w[i] for i in range(len(v))]

def sum(v, w): return [v[i] + w[i] for i in range(len(v))]

def sMul(a, v): return [a * v[i] for i in range(len(v))]

def genLinearIndipendentVectors(w):
    vectorList = []

    vectorList.append(w)
    isFirstNonZeroEntry = True
    for i in range(len(w)):

	if (isFirstNonZeroEntry and w[i] != 0): 
	    isFirstNonZeroEntry = False
	    continue
    
	vector = ([0] * len(w))
	vector[i] = 1
  	vectorList.append(vector)

    return vectorList

def getOrthonormalBasis(v):
    e = [None] * len(v)

    for j in range(len(v)):
	e[j] = list(v[j])

	for k in range(j):
	    proj_vjek = sMul(-dotProduct(v[j], e[k]), e[k])
 	    e[j] = sum(e[j], proj_vjek)
	e[j] = sMul(1 / norm(e[j]), e[j])

    return e

def getRandomSequence(w, theta, basis, steps):
    r = [0] * len(w)

    normalizingFactor = 0
    for i in range(len(basis)):
	entry = random.gauss(0, 1)
	normalizingFactor += entry**2
	r = sum(r, sMul(entry, basis[i]))

    path = []
    for i in range(1, steps + 1):
	cosTheta = math.cos(math.radians(theta * i))
 	sinTheta = math.sin(math.radians(theta * i))
	
 	if cosTheta == 0:
	    stepVector = [signum(sinTheta) * x * r[i] for i in range(len(w))]
	else:
	    x = (1 / math.sqrt(normalizingFactor)) * math.sqrt(1 / cosTheta**2 - 1)    
	    stepVector = [signum(sinTheta) * x * r[i] + signum(cosTheta) * w[i] for i in range(len(w))]

	path.append(sMul(1 / norm(stepVector), stepVector))

    return path

def generateExamplesWithMargin(w, examplesCount, margin):
    theta = math.degrees(math.acos(margin))

    basis = getOrthonormalBasis(genLinearIndipendentVectors(w))
    examples = []
    for i in range(examplesCount):
	
 	label = random.choice([0, 1])
	if label == 1:
	    # v = getRandomSequence(w, random.uniform(0, theta), basis[1:], 1)[0]
	    v = getRandomSequence(w, theta, basis[1:], 1)[0]
	else:
	    # v = getRandomSequence(w, random.uniform(180, 180 - theta), basis[1:], 1)[0]
	    v = getRandomSequence(w, 180 - theta, basis[1:], 1)[0]
	examples.append((sMul(1 / norm(v), v), label))

    return examples

def writeExamples(outStream, examples, baseNumber):
    for i in range(len(examples)):
	instance = examples[i][0]
	label = examples[i][1]

	print >> outStream, "example" + str(baseNumber + i) + " " + str(label) + " =",

	for j in range(len(instance)):
	    value = instance[j]
	    print >> outStream, str(j) + ":%0.7f" % value,

        print >> outStream, ""


if __name__ == "__main__":

    random.seed()

    blockSize = 4000
    hyperPlanesCount = 2
    rotation = 100
    n = 3
    trainingSetSize = 4000
    testSetSize = 2000
    minMarginTrainingSet = 0.2
    minMarginTestSet = 0.2
#     minMarginTrainingSet = 0.05
#     minMarginTestSet = 0.05


    w = [random.gauss(0, 1) for i in range(n)]
    w = sMul(1 / norm(w), w)

    hyperPlanesDistribution = [0] * max(1, (hyperPlanesCount / 2))
    for i in range(hyperPlanesCount):
	hyperPlanesDistribution[random.choice(range(len(hyperPlanesDistribution)))] += 1

    path = []
    for i in range(len(hyperPlanesDistribution)):
	print "generating partial path...[" + str(hyperPlanesDistribution[i]) + " hyperPlanes]"
	basis = getOrthonormalBasis(genLinearIndipendentVectors(w))
 	partialPath = getRandomSequence(w, rotation, basis[1:], hyperPlanesDistribution[i])
  	w = partialPath[len(partialPath) - 1]
 	path += partialPath

    print len(path)

#     print "generating training set..."

#     trainingSet = open("synthetic4-train.data", "w")
#     for j in range(len(path)):

# 	for blockCount in range(int(trainingSetSize / blockSize)):
# 	    examples = generateExamplesWithMargin(path[j], blockSize, 
# 						      minMarginTrainingSet)
# 	    writeExamples(trainingSet, examples, (j * trainingSetSize) + blockCount * blockSize)
#     trainingSet.close()
