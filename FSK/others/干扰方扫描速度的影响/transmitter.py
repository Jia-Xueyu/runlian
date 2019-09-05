import matlab.engine
eng=matlab.engine.start_matlab()
import threading
import time
from datetime import datetime
import sys

information=eng.information()

class myTransmitter(threading.Thread):
	def __init__(self,start,s_f1,s_f2,r_f1,r_f2,change,index,signalnum,decode_index,code,preamble,signal,information,ack,ack_code,trans_again,record_notation):
		self.start=start
		self.s_f1=s_f1
		self.s_f2=s_f2
		self.r_f1=r_f1
		self.r_f2=r_f2
		self.change=change
		self.index=index
		self.signalnum=signalnum
		self.decode_index=decode_index
		self.code=code
		self.preamble=preamble
		self.signal=signal
		self.information=information
		self.ack=ack
		self.ack_code=ack_code
		self.trans_again=trans_again
		self.record_notation=record_notation
		self.oldtime=0;
		self.newtime=0;

	def transmit(self):
		filename='./information/infor'+str(self.index)+'_'+str(int(self.s_f1/1000))+str(int(self.s_f2/1000))+'.wav'
		if self.trans_again==0:
			self.oldtime=datetime.now();
			if self.start==1:
				print('transmit',filename,self.s_f1)
				#temp=eng.t_send(self.s_f1,self.s_f2,self.index,self.information)
				temp=eng.voice(filename,25)
				self.trans_again=1
				self.index=self.index+1
				self.start=0
			else:
				if self.ack==1 or self.change==1:
					print('transmit ',filename,self.s_f1)
					#temp=eng.t_send(self.s_f1,self.s_f2,self.index,self.information)
					temp=eng.voice(filename,25)
					self.index=self.index+1
					self.trans_again=1
					self.ack=0
					self.change=0
		else:
			self.newtime=datetime.now()
			if (self.newtime-self.oldtime).seconds>120:
				self.oldtime=datetime.now();
				print('reaudio')
				file='./information/infor'+str(self.index-1)+'_'+str(int(self.s_f1/1000))+str(int(self.s_f2/1000))+'.wav'
				temp=eng.voice(file,25);

	def t_record(self):
		if self.record_notation==1:
			print('t_record')
			temp=eng.t_record(self.signalnum)
			self.signalnum=self.signalnum+1
			self.record_notation=0

	def t_decode(self):
		#print('t_decode')
		temp=eng.t_decode(self.decode_index,self.r_f1,self.r_f2)
		if len(temp)>0:
			Temp=temp[0]
			for i in Temp:
				if i==1.0:
					self.code.append(1)
				else:
					self.code.append(0)
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

	def analysis(self):
		#print('analysis')
		if len(self.code)>0:
			for i in self.code[0:3]:
				self.preamble.append(i)
			if self.preamble==[1,0,1]:
				self.preamble=[]
				diff=[]
				count=0
				for i in range(5):
					diff.append(self.code[3+i]==0)
				for i in range(5):
					if diff[i]==False:
						count=count+1
				if count<=2:
					self.change=1
				else:
					self.ack=1
			else:
				self.preamble=[]
				self.change=0
				self.ack=0
				self.code=[]
			if self.change==1:
				for i in self.code[3:]:
					self.signal.append(i)
				self.code=[]
				print(self.signal)
				if self.s_f1==18000:
					self.s_f1=17000
					self.s_f2=18000
					self.r_f1=19000
					self.r_f2=20000
					self.trans_again=0
				else:
					self.s_f1=18000
					self.s_f2=19000
					self.r_f1=20000
					self.r_f2=21000
					self.trans_again=0
				self.signal=[]
			if self.ack==1:
				for i in self.code[3:]:
					self.ack_code.append(i)
				self.code=[]
				print(self.ack_code)
				print('next')
				self.ack_code=[]
				self.trans_again=0
				self.ack=1
				
			

	def loop_transmit(self):
		while True:
			if self.index>10:
				sys.exit()
			self.transmit()

	def loop_t_record(self):
		while True:
			if self.index>10:
				sys.exit()
			self.t_record()

	def loop_t_decode(self):
		while True:
			if self.index>10:
				sys.exit()
			self.t_decode()

	def loop_analysis(self):
		while True:
			if self.index>10:
				sys.exit()
			self.analysis()
	def loop_notation(self):
		while True:
			if self.index>10:
				sys.exit()
			self.notation()


def save_to_file(file_name, contents):
	    fh = open(file_name, 'w')
	    temp=contents[0]
	    Temp=[]
	    for i in temp:
	    	if i==1.0:
	    		Temp.append('1')
	    	else:
	    		Temp.append('0')
	    con=" ".join(Temp)
	    fh.write(con)
	    fh.close()

#save_to_file('information_original.txt', information)

mytransmitter=myTransmitter(1,17000,18000,19000,20000,0,1,1,1,[],[],[],information,0,[],0,0)
threads=[]
t1=threading.Thread(target=mytransmitter.loop_transmit)
t2=threading.Thread(target=mytransmitter.loop_t_record)
t3=threading.Thread(target=mytransmitter.loop_t_decode)
t4=threading.Thread(target=mytransmitter.loop_analysis)
t5=threading.Thread(target=mytransmitter.loop_notation)


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
#while True:
#	print('resend')
#	if msvcrt.getch() == b'a':#按a键发送方发送，否则接收
#		mytransmitter.transmit()
#		mytransmitter.add_index()
#	elif msvcrt.getch() == b'p':
#		fo = open("information_original.txt", "w")
#		print(information)
#		fo.close()
#	else:
#		mytransmitter.t_record_decode()

