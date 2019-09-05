import matlab.engine
eng=matlab.engine.start_matlab()
import threading
import time
from datetime import datetime
import sys

validation=[1,1,1,0,1,1,1,0,1,1,1]
flag=0

class myReceiver(threading.Thread):
	def __init__(self,s_f1,s_f2,r_f1,r_f2,validation,infor,signalnum,decode_index,code,trans,flag,write_flag,preamble,record_notation):
		self.s_f1=s_f1
		self.s_f2=s_f2
		self.r_f1=r_f1
		self.r_f2=r_f2
		self.validation=validation
		self.infor=[]
		self.signalnum=signalnum
		self.decode_index=decode_index
		self.code=code
		self.trans=trans
		self.flag=flag
		self.write_flag=write_flag
		self.preamble=preamble
		self.record_notation=record_notation
		self.oldtime=0
		self.newtime=0
		self.ack=0

	def writedown(self):
		if self.write_flag==1:
			print('write down')
			self.write_flag=0
			with open('information.txt', 'a+') as f:
				con=" ".join(self.infor)
				self.infor=[]
				con=' '+con
				f.write(con)

	def r_record(self):
		if self.record_notation==1:
			print('t_record')
			temp=eng.r_record(self.signalnum)
			self.signalnum=self.signalnum+1
			self.record_notation=0
			self.ack=1

	def r_decode(self):
		#print('t_decode')
		Temp=eng.r_decode(self.decode_index,self.r_f1,self.r_f2)
		if len(Temp)>0:
			temp=Temp[0]
			for i in temp:
				if i==1.0:
					self.code.append('1')
				else:
					self.code.append('0')
			self.decode_index=self.decode_index+1
			print(self.code)

	def notation(self):
		temp=eng.notation(self.r_f1,self.r_f2)
		if temp==0.0:
			self.record_notation=0
		else:
			self.record_notation=1
			time.sleep(2)
		print(self.record_notation)

	def sendACK(self):
		filename='./ACK/ACK'+str(int(self.s_f1/1000))+str(int(self.s_f2/1000))+'T'+'.wav'
		temp=eng.voice(filename,8)

	def analysis(self):
		#print('analysis')
		self.newtime=datetime.now()
		if self.ack==1 and self.trans==1 and (self.newtime-self.oldtime).seconds>10:
			self.sendACK()
		#print(self.infor)
		if len(self.code)>0:
			for i in self.code[0:3]:
				self.preamble.append(i)
			print('receive')
			self.trans=1
			if self.trans==1:
				self.trans=0
				self.validation=[]
				temp=[]
				for i in range(21):
					if i%2==0:
						self.validation.append(self.code[i+3])
					else:
						temp.append(self.code[i+3])
				self.code=[]
				self.write_flag=1
				self.oldtime=datetime.now()
				for i in temp:
					self.infor.append(i)
				self.sendACK()
			else:
				self.code=[]
				self.trans=0



	def loop_record(self):
		while True:
			if self.decode_index>10:
				sys.exit()
			self.r_record()

	def loop_decode(self):
		while True:
			if self.decode_index>10:
				sys.exit()
			self.r_decode()
	def loop_analysis(self):
		while True:
			if self.decode_index>10 and len(self.code)==0:
				sys.exit()
			self.analysis()
	def loop_write(self):
		while True:
			if self.decode_index>10 and self.write_flag==0 and len(self.code)==0:
				sys.exit()
			self.writedown()

	def loop_notation(self):
		while True:
			if self.decode_index>10:
				sys.exit()
			self.notation()





myreceiver=myReceiver(19000,20000,17000,18000,[],[],1,1,[],0,0,0,[],0)
t1=threading.Thread(target=myreceiver.loop_record)
t2=threading.Thread(target=myreceiver.loop_decode)
t3=threading.Thread(target=myreceiver.loop_analysis)
t4=threading.Thread(target=myreceiver.loop_write)
t5=threading.Thread(target=myreceiver.loop_notation)


t2.start()
t1.start()
t3.start()
t4.start()
t5.start()
t1.join()
t2.join()
t3.join()
t4.join()
t5.join()
'''
while True:
	print('reReceive')
	if msvcrt.getch() == b'a':#按a键接收方接收
		myreceiver.receive()
	if msvcrt.getch() == b'p':
		myreceiver.print()
		'''