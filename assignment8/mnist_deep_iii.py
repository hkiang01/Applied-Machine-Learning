from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

import tensorflow as tf
sess = tf.InteractiveSession()
x = tf.placeholder(tf.float32, [None, 784])
W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))
y = tf.nn.softmax(tf.matmul(x, W) + b)
y_ = tf.placeholder(tf.float32, [None, 10])

init = tf.initialize_all_variables()

def weight_variable(shape):
  initial = tf.truncated_normal(shape, stddev=0.1)
  return tf.Variable(initial)

def bias_variable(shape):
  initial = tf.constant(0.1, shape=shape)
  return tf.Variable(initial)

def conv2d(x, W):
  return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='SAME')

def max_pool_2x2(x):
  return tf.nn.max_pool(x, ksize=[1, 2, 2, 1],
                        strides=[1, 2, 2, 1], padding='SAME')

W_conv1 = weight_variable([3, 3, 1, 8])
b_conv1 = bias_variable([8])

x_image = tf.reshape(x, [-1,28,28,1])

h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)

W_conv2 = weight_variable([3, 3, 8, 16])
b_conv2 = bias_variable([16])

h_conv2 = tf.nn.relu(conv2d(h_conv1, W_conv2) + b_conv2)

W_conv3 = weight_variable([3, 3, 16, 32])
b_conv3 = bias_variable([32])

h_conv3 = tf.nn.relu(conv2d(h_conv2, W_conv3) + b_conv3)

W_fc1 = weight_variable([28 * 28 * 32, 1024])
b_fc1 = bias_variable([1024])

h_conv_final = tf.reshape(h_conv3, [-1, 28*28*32])
h_fc1 = tf.nn.relu(tf.matmul(h_conv_final, W_fc1) + b_fc1)

keep_prob = tf.placeholder(tf.float32)
h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)

W_fc2 = weight_variable([1024, 10])
b_fc2 = bias_variable([10])

y_conv=tf.nn.softmax(tf.matmul(h_fc1_drop, W_fc2) + b_fc2)

with tf.name_scope('cross_entropy'):
  cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y_conv), reduction_indices=[1]))
  tf.scalar_summary('cross entropy', cross_entropy)


with tf.name_scope('accuracy'):
  with tf.name_scope('correct_prediction'):
    correct_prediction = tf.equal(tf.argmax(y_conv,1), tf.argmax(y_,1))
  with tf.name_scope('accuracy'):
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
  tf.scalar_summary('accuracy', accuracy)

with tf.name_scope('train'):
  train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)

merged = tf.merge_all_summaries()
train_writer = tf.train.SummaryWriter('/tmp/mnist_logs4' + '/train', sess.graph)
test_writer = tf.train.SummaryWriter('/tmp/mnist_logs4' + '/test')



tf.initialize_all_variables().run()
for i in range(20000):
  batch = mnist.train.next_batch(50)
  if i%100 == 0:
    summary, test_accuracy = sess.run([merged, accuracy], feed_dict={x: mnist.test.images, y_: mnist.test.labels, keep_prob: 1.0})
    test_writer.add_summary(summary, i)
    print("step %d, training accuracy %g"%(i, test_accuracy))
  summary,_ = sess.run([merged, train_step], feed_dict={x: batch[0], y_: batch[1], keep_prob: 0.5})
  train_writer.add_summary(summary, i)

summary, test_accuracy = sess.run([merged, accuracy], feed_dict={x: mnist.test.images, y_: mnist.test.labels, keep_prob: 1.0})
print("test accuracy %g"%test_accuracy)


