# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: t -*-
# vi: set ft=python sts=4 ts=4 sw=4 noet :

# This file is part of Fail2Ban.
#
# Fail2Ban is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Fail2Ban is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Fail2Ban; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

__author__ = "Cyril Jaquier, Yaroslav Halchenko"
__copyright__ = "Copyright (c) 2004 Cyril Jaquier, 2011-2013 Yaroslav Halchenko"
__license__ = "GPL"

import os, glob, tempfile, shutil, unittest

from client.configreader import ConfigReader
from client.jailreader import JailReader
from client.jailsreader import JailsReader
from client.configurator import Configurator
from utils import LogCaptureTestCase

class ConfigReaderTest(unittest.TestCase):

	def setUp(self):
		"""Call before every test case."""
		self.d = tempfile.mkdtemp(prefix="f2b-temp")
		self.c = ConfigReader(basedir=self.d)

	def tearDown(self):
		"""Call after every test case."""
		shutil.rmtree(self.d)

	def _write(self, fname, value):
		# verify if we don't need to create .d directory
		if os.path.sep in fname:
			d = os.path.dirname(fname)
			d_ = os.path.join(self.d, d)
			if not os.path.exists(d_):
				os.makedirs(d_)
		open("%s/%s" % (self.d, fname), "w").write("""
[section]
option = %s
""" % value)

	def _remove(self, fname):
		os.unlink("%s/%s" % (self.d, fname))
		self.assertTrue(self.c.read('c'))	# we still should have some


	def _getoption(self, f='c'):
		self.assertTrue(self.c.read(f))	# we got some now
		return self.c.getOptions('section', [("int", 'option')])['option']


	def testInaccessibleFile(self):
		f = os.path.join(self.d, "d.conf")  # inaccessible file
		self._write('d.conf', 0)
		self.assertEqual(self._getoption('d'), 0)
		os.chmod(f, 0)
		# fragile test and known to fail e.g. under Cygwin where permissions
		# seems to be not enforced, thus condition
		if not os.access(f, os.R_OK):
			self.assertFalse(self.c.read('d'))	# should not be readable BUT present
		else:
			# SkipTest introduced only in 2.7 thus can't yet use generally
			# raise unittest.SkipTest("Skipping on %s -- access rights are not enforced" % platform)
			pass


	def testOptionalDotDDir(self):
		self.assertFalse(self.c.read('c'))	# nothing is there yet
		self._write("c.conf", "1")
		self.assertEqual(self._getoption(), 1)
		self._write("c.conf", "2")		# overwrite
		self.assertEqual(self._getoption(), 2)
		self._write("c.d/98.conf", "998") # add 1st override in .d/
		self.assertEqual(self._getoption(), 998)
		self._write("c.d/90.conf", "990") # add previously sorted override in .d/
		self.assertEqual(self._getoption(), 998) #  should stay the same
		self._write("c.d/99.conf", "999") # now override in a way without sorting we possibly get a failure
		self.assertEqual(self._getoption(), 999)
		self._remove("c.d/99.conf")
		self.assertEqual(self._getoption(), 998)
		self._remove("c.d/98.conf")
		self.assertEqual(self._getoption(), 990)
		self._remove("c.d/90.conf")
		self.assertEqual(self._getoption(), 2)
		self._write("c.local", "3")		# add override in .local
		self.assertEqual(self._getoption(), 3)
		self._write("c.d/5.local", "9")		# add override in c.d/*.local
		self.assertEqual(self._getoption(), 9)
		self._remove("c.conf")			#  we allow to stay without .conf
		self.assertEqual(self._getoption(), 9)
		self._write("c.conf", "1")
		self._remove("c.d/5.local")
		self._remove("c.local")
		self.assertEqual(self._getoption(), 1)


class JailReaderTest(LogCaptureTestCase):

	def testJailActionEmpty(self):
		jail = JailReader('emptyaction', basedir=os.path.join('testcases','config'))
		self.assertTrue(jail.read())
		self.assertTrue(jail.getOptions())
		self.assertTrue(jail.isEnabled())
		self.assertTrue(self._is_logged('No filter set for jail emptyaction'))
		self.assertTrue(self._is_logged('No actions were defined for emptyaction'))

	def testJailActionFilterMissing(self):
		jail = JailReader('missingbitsjail', basedir=os.path.join('testcases','config'))
		self.assertTrue(jail.read())
		self.assertFalse(jail.getOptions())
		self.assertTrue(jail.isEnabled())
		self.assertTrue(self._is_logged("Found no accessible config files for 'filter.d/catchallthebadies' under testcases/config"))
		self.assertTrue(self._is_logged('Unable to read the filter'))

	def testJailActionBrokenDef(self):
		jail = JailReader('brokenactiondef', basedir=os.path.join('testcases','config'))
		self.assertTrue(jail.read())
		self.assertFalse(jail.getOptions())
		self.assertTrue(jail.isEnabled())
		self.assertTrue(self._is_logged('Error in action definition joho[foo'))
		self.assertTrue(self._is_logged('Caught exception: While reading action joho[foo we should have got 1 or 2 groups. Got: 0'))

	def testStockSSHJail(self):
		jail = JailReader('ssh-iptables', basedir='config') # we are running tests from root project dir atm
		self.assertTrue(jail.read())
		self.assertTrue(jail.getOptions())
		self.assertFalse(jail.isEnabled())
		self.assertEqual(jail.getName(), 'ssh-iptables')
		jail.setName('ssh-funky-blocker')
		self.assertEqual(jail.getName(), 'ssh-funky-blocker')

	def testSplitAction(self):
		action = "mail-whois[name=SSH]"
		expected = ['mail-whois', {'name': 'SSH'}]
		result = JailReader.splitAction(action)
		self.assertEqual(expected, result)

		self.assertEqual(['mail.who_is', {}], JailReader.splitAction("mail.who_is"))
		self.assertEqual(['mail.who_is', {'a':'cat', 'b':'dog'}], JailReader.splitAction("mail.who_is[a=cat,b=dog]"))
		self.assertEqual(['mail--ho_is', {}], JailReader.splitAction("mail--ho_is"))

		self.assertEqual(['mail--ho_is', {}], JailReader.splitAction("mail--ho_is['s']"))
		self.assertTrue(self._is_logged("Invalid argument ['s'] in ''s''"))

		self.assertEqual(['mail', {'a': ','}], JailReader.splitAction("mail[a=',']"))
		
		self.assertRaises(ValueError, JailReader.splitAction ,'mail-how[')


	def testGlob(self):
		d = tempfile.mkdtemp(prefix="f2b-temp")
		# Generate few files
		# regular file
		f1 = os.path.join(d, 'f1')
		open(f1, 'w').close()
		# dangling link
		
		f2 = os.path.join(d, 'f2')
		os.symlink('nonexisting',f2)

		# must be only f1
		self.assertEqual(JailReader._glob(os.path.join(d, '*')), [f1])
		# since f2 is dangling -- empty list
		self.assertEqual(JailReader._glob(f2), [])
		self.assertTrue(self._is_logged('File %s is a dangling link, thus cannot be monitored' % f2))
		self.assertEqual(JailReader._glob(os.path.join(d, 'nonexisting')), [])
		os.remove(f1)
		os.remove(f2)
		os.rmdir(d)

class JailsReaderTest(LogCaptureTestCase):

	def testProvidingBadBasedir(self):
		if not os.path.exists('/XXX'):
			reader = JailsReader(basedir='/XXX')
			self.assertRaises(ValueError, reader.read)

	def testReadTestJailConf(self):
		jails = JailsReader(basedir=os.path.join('testcases','config'))
		self.assertTrue(jails.read())
		self.assertFalse(jails.getOptions())
		self.assertRaises(ValueError, jails.convert)
		comm_commands = jails.convert(allow_no_files=True)
		self.maxDiff = None
		self.assertEqual(sorted(comm_commands),
			sorted([['add', 'emptyaction', 'auto'],
			 ['set', 'emptyaction', 'usedns', 'warn'],
			 ['set', 'emptyaction', 'maxretry', 3],
			 ['set', 'emptyaction', 'findtime', 600],
			 ['set', 'emptyaction', 'bantime', 600],
			 ['add', 'special', 'auto'],
			 ['set', 'special', 'usedns', 'warn'],
			 ['set', 'special', 'maxretry', 3],
			 ['set', 'special', 'addfailregex', '<IP>'],
			 ['set', 'special', 'findtime', 600],
			 ['set', 'special', 'bantime', 600],
			 ['add', 'missinglogfiles', 'auto'],
			 ['set', 'missinglogfiles', 'usedns', 'warn'],
			 ['set', 'missinglogfiles', 'maxretry', 3],
			 ['set', 'missinglogfiles', 'findtime', 600],
			 ['set', 'missinglogfiles', 'bantime', 600],
			 ['set', 'missinglogfiles', 'addfailregex', '<IP>'],
			 ['add', 'brokenaction', 'auto'],
			 ['set', 'brokenaction', 'usedns', 'warn'],
			 ['set', 'brokenaction', 'maxretry', 3],
			 ['set', 'brokenaction', 'findtime', 600],
			 ['set', 'brokenaction', 'bantime', 600],
			 ['set', 'brokenaction', 'addfailregex', '<IP>'],
			 ['set', 'brokenaction', 'addaction', 'brokenaction'],
			 ['set',
			  'brokenaction',
			  'actionban',
			  'brokenaction',
			  'hit with big stick <ip>'],
			 ['set', 'brokenaction', 'actionstop', 'brokenaction', ''],
			 ['set', 'brokenaction', 'actionstart', 'brokenaction', ''],
			 ['set', 'brokenaction', 'actionunban', 'brokenaction', ''],
			 ['set', 'brokenaction', 'actioncheck', 'brokenaction', ''],
			 ['add', 'parse_to_end_of_jail.conf', 'auto'],
			 ['set', 'parse_to_end_of_jail.conf', 'usedns', 'warn'],
			 ['set', 'parse_to_end_of_jail.conf', 'maxretry', 3],
			 ['set', 'parse_to_end_of_jail.conf', 'findtime', 600],
			 ['set', 'parse_to_end_of_jail.conf', 'bantime', 600],
			 ['set', 'parse_to_end_of_jail.conf', 'addfailregex', '<IP>'],
			 ['start', 'emptyaction'],
			 ['start', 'special'],
			 ['start', 'missinglogfiles'],
			 ['start', 'brokenaction'],
			 ['start', 'parse_to_end_of_jail.conf'],]))
		self.assertTrue(self._is_logged("Errors in jail 'missingbitsjail'. Skipping..."))
		self.assertTrue(self._is_logged("No file(s) found for glob /weapons/of/mass/destruction"))


	def testReadStockJailConf(self):
		jails = JailsReader(basedir='config') # we are running tests from root project dir atm
		self.assertTrue(jails.read())		  # opens fine
		self.assertTrue(jails.getOptions())	  # reads fine
		comm_commands = jails.convert()
		# by default None of the jails is enabled and we get no
		# commands to communicate to the server
		self.maxDiff = None
		self.assertEqual(comm_commands, [])

		# We should not "read" some bogus jail
		old_comm_commands = comm_commands[:]   # make a copy
		self.assertFalse(jails.getOptions("BOGUS"))
		self.assertTrue(self._is_logged("No section: 'BOGUS'"))
		# and there should be no side-effects
		self.assertEqual(jails.convert(), old_comm_commands)

	def testReadSockJailConfComplete(self):
		jails = JailsReader(basedir='config', force_enable=True)
		self.assertTrue(jails.read())		  # opens fine
		self.assertTrue(jails.getOptions())	  # reads fine
		# grab all filter names
		filters = set(os.path.splitext(os.path.split(a)[1])[0]
			for a in glob.glob(os.path.join('config', 'filter.d', '*.conf'))
				if not a.endswith('common.conf'))
		filters_jail = set(jail.getRawOptions()['filter'] for jail in jails.getJails())
		self.maxDiff = None
		self.assertTrue(filters.issubset(filters_jail),
			"More filters exists than are referenced in stock jail.conf %r" % filters.difference(filters_jail))
		self.assertTrue(filters_jail.issubset(filters),
			"Stock jail.conf references non-existent filters %r" % filters_jail.difference(filters))

	def testReadStockJailConfForceEnabled(self):
		# more of a smoke test to make sure that no obvious surprises
		# on users' systems when enabling shipped jails
		jails = JailsReader(basedir='config', force_enable=True) # we are running tests from root project dir atm
		self.assertTrue(jails.read())		  # opens fine
		self.assertTrue(jails.getOptions())	  # reads fine
		comm_commands = jails.convert(allow_no_files=True)

		# by default we have lots of jails ;)
		self.assertTrue(len(comm_commands))

		# and we know even some of them by heart
		for j in ['ssh-iptables', 'recidive']:
			# by default we have 'auto' backend ATM
			self.assertTrue(['add', j, 'auto'] in comm_commands)
			# and warn on useDNS
			self.assertTrue(['set', j, 'usedns', 'warn'] in comm_commands)
			self.assertTrue(['start', j] in comm_commands)

		# last commands should be the 'start' commands
		self.assertEqual(comm_commands[-1][0], 'start')

		for j in  jails._JailsReader__jails:
			actions = j._JailReader__actions
			jail_name = j.getName()
			# make sure that all of the jails have actions assigned,
			# otherwise it makes little to no sense
			self.assertTrue(len(actions),
							msg="No actions found for jail %s" % jail_name)

			# Test for presence of blocktype (in relation to gh-232)
			for action in actions:
				commands = action.convert()
				file_ = action.getFile()
				if '<blocktype>' in str(commands):
					# Verify that it is among cInfo
					self.assertTrue('blocktype' in action._ActionReader__cInfo)
					# Verify that we have a call to set it up
					blocktype_present = False
					target_command = [ 'set', jail_name, 'setcinfo', file_, 'blocktype' ]
					for command in commands:
						if (len(command) > 5 and
							command[:5] == target_command):
							blocktype_present = True
							continue
					self.assertTrue(
						blocktype_present,
						msg="Found no %s command among %s"
						    % (target_command, str(commands)) )


	def testConfigurator(self):
		configurator = Configurator()
		configurator.setBaseDir('config')
		self.assertEqual(configurator.getBaseDir(), 'config')

		configurator.readEarly()
		opts = configurator.getEarlyOptions()
		# our current default settings
		self.assertEqual(opts['socket'], '/var/run/fail2ban/fail2ban.sock')
		self.assertEqual(opts['pidfile'], '/var/run/fail2ban/fail2ban.pid')

		configurator.getOptions()
		configurator.convertToProtocol()
		commands = configurator.getConfigStream()
		# and there is logging information left to be passed into the
		# server
		self.assertEqual(sorted(commands),
						 [['set', 'loglevel', 3],
						  ['set', 'logtarget', '/var/log/fail2ban.log']])

		# and if we force change configurator's fail2ban's baseDir
		# there should be an error message (test visually ;) --
		# otherwise just a code smoke test)
		configurator._Configurator__jails.setBaseDir('/tmp')
		self.assertEqual(configurator._Configurator__jails.getBaseDir(), '/tmp')
		self.assertEqual(configurator.getBaseDir(), 'config')
