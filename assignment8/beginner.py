# Title: MNIST Tutorial for Beginners - TensorFlow
# Source: https://www.tensorflow.org/versions/master/tutorials/mnist/beginners/index.html
# Author: Harrison Kiang, 2016
# Description: Softmax model on MNIST dataset

# Import MNIST dataset
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

# import tensorflow
import tensorflow as tf

# x is a placeholder value that's an input to a TensorFlow computation
# want to flatten each input image into 784 dimensional vector
x = tf.placeholder(tf.float32, [None, 784])


# model parameters are generally Variables
# W is a variable with weights, b is a variable with biases for each class
# initialized as tensors full of zeros
W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))

# note that W is 784x10, as each image is a 784 dimensional vector
# result is a size 10, consisting of normalized proabilities of classes

# implement softmax model
y = tf.nn.softmax(tf.matmul(x,W) + b)

# implement cross-entropy as the cost function
y_ = tf.placeholder(tf.float32, [None, 10]) # hold correct answers
cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y), reduction_indices=[1]))
# note: reduction_indices=[1] causes tf.reduce_sum to add the second dimension of y


# TensorFlow is able to automatically backpropagate to efficiently
# determine affect of variables on cost that is to be minimized
train_step = tf.train.GradientDescentOptimizer(0.5).minimize(cross_entropy) # learning rate=0.5

##########################
########## MAIN ##########
##########################

# initialize the variables created
init = tf.initialize_all_variables()

# launch the model in a Session, run the operation that initializes the variables
sess = tf.Session()
sess.run(init)

# stochastic training with random batches
for i in range(1000):
	# get a 'batch' of 100 random data points
	batch_xs, batch_ys = mnist.train.next_batch(100)
	# run train_step, replace placeholders with batches data
	sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})

# check the prediction
# y is prediction, y_ is truth
correct_prediction = tf.equal(tf.argmax(y,1), tf.argmax(y_,1)) # binary vector of 0's and 1's

# accuracy
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

# ask for accuracy of test data, should be around 92% for softmax, 97% for better algo's
print(sess.run(accuracy, feed_dict={x: mnist.test.images, y_:mnist.test.labels}))
