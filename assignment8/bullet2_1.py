from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

import tensorflow as tf

flags = tf.app.flags
FLAGS = flags.FLAGS
flags.DEFINE_string('summaries_dir', '/tmp/mnist_logs1', 'Summaries directory')
flags.DEFINE_integer('max_steps', 2000, 'Number of steps to run trainer.')
flags.DEFINE_boolean('enable_max_pooling', True, 'If true, uses max pooling')

# prevents multiple graphs warning in tensorboard
if tf.gfile.Exists(FLAGS.summaries_dir):
  tf.gfile.DeleteRecursively(FLAGS.summaries_dir)
tf.gfile.MakeDirs(FLAGS.summaries_dir)

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

# First convolutional layer (8 features for each 5x5 patch)
# note 32 input channels, 8 output channels
W_conv1 = weight_variable([5, 5, 1, 8])
b_conv1 = bias_variable([8])

x_image = tf.reshape(x, [-1,28,28,1])

h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)
h_pool1 = max_pool_2x2(h_conv1)

# Second convolutional layer (16 features for each 5x5 patch)
# note 8 input channels, 16 output channels
# 4 nodes in this layer
W_conv2_1 = weight_variable([5, 5, 8, 16])
b_conv2_1 = bias_variable([16])
W_conv2_2 = weight_variable([5, 5, 8, 16])
b_conv2_2 = bias_variable([16])
W_conv2_3 = weight_variable([5, 5, 8, 16])
b_conv2_3 = bias_variable([16])
W_conv2_4 = weight_variable([5, 5, 8, 16])
b_conv2_4 = bias_variable([16])

h_conv2_1 = tf.nn.relu(conv2d(h_pool1, W_conv2_1) + b_conv2_1)
h_conv2_2 = tf.nn.relu(conv2d(h_pool1, W_conv2_2) + b_conv2_2)
h_conv2_3 = tf.nn.relu(conv2d(h_pool1, W_conv2_3) + b_conv2_3)
h_conv2_4 = tf.nn.relu(conv2d(h_pool1, W_conv2_4) + b_conv2_4)

if FLAGS.enable_max_pooling:
  h_pool2_1 = max_pool_2x2(h_conv2_1)
  h_pool2_2 = max_pool_2x2(h_conv2_2)
  h_pool2_3 = max_pool_2x2(h_conv2_3)
  h_pool2_4 = max_pool_2x2(h_conv2_4)

if FLAGS.enable_max_pooling:
  h_pool2_combined = tf.concat(0,[h_pool2_1, h_pool2_2, h_pool2_3, h_pool2_4])
else:
  h_pool2_combined = tf.concat(0,[h_conv2_1, h_conv2_2, h_conv2_3, h_conv2_4])

h_pool2_flat = tf.reshape(h_pool2_combined, [-1, 7*7*64])

# image size reduced to 7x7
# add a fully-connected layer with 1024 neurons to allow for full image processing
W_fc1 = weight_variable([7 * 7 * 64, 1024])
b_fc1 = bias_variable([1024])

h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)

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
train_writer = tf.train.SummaryWriter(FLAGS.summaries_dir + '/train', sess.graph)
test_writer = tf.train.SummaryWriter(FLAGS.summaries_dir + '/test')

tf.initialize_all_variables().run()
for i in range(FLAGS.max_steps + 1): # +1 to prevent necessity of repeating code in if block, graph error
  batch = mnist.train.next_batch(50)
  if i%100 == 0:
    summary, test_accuracy = sess.run([merged, accuracy], feed_dict={x: mnist.test.images, y_: mnist.test.labels, keep_prob: 1.0})
    test_writer.add_summary(summary, i)
    print("Accuracy at step %s: %s"%(i, test_accuracy))
  summary,_ = sess.run([merged, train_step], feed_dict={x: batch[0], y_: batch[1], keep_prob: 0.5})
  train_writer.add_summary(summary, i)
