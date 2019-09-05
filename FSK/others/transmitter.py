import matlab.engine
eng=matlab.engine.start_matlab()
import threading
import time

information=eng.information()
band=[[17000,18000],[18000,19000],[19000,20000],[20000,21000]]

class myTransmitter(threading.Thread):
	def __init__(self,start,s_f1,s_f2,r_f1,r_f2,change,index,signalnum,decode_index,code,code_index,preamble,signal,information,ack):
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
		self.code_index=code_index
		self.preamble=preamble
		self.signal=signal
		self.information=information
		self.ack=ack

	def transmit(self):
		
		print(self.s_f1,self.s_f2)
		if self.start==1:
			print('transmit')
			temp=eng.t_send(self.s_f1,self.s_f2,self.index,self.information)
			self.index=self.index+10
			self.start=0
		else:
			if self.ack==1:
				print('transmit')
				temp=eng.t_send(self.s_f1,self.s_f2,self.index,self.information)
				self.index=self.index+10

	def t_record(self):
		print('t_record')
		temp=eng.t_record(self.signalnum)
		self.signalnum=self.signalnum+1

	def t_decode(self):
		print('t_decode')
		temp=eng.t_decode(self.decode_index,self.r_f1,self.r_f2)
		Temp=temp[0]
		for i in Temp:
			if i==1.0:
				self.code.append(1)
			else:
				self.code.append(0)
		self.decode_index=self.decode_index+1

	def analysis(self):
		print('analysis')
		if len(self.code)>0 and self.code_index<(self.decode_index-1)*8:
			for i in self.code[self.code_index:]:
				self.code_index=self.code_index+1
				self.preamble.append(i)
				if len(self.preamble)==4:
					if(self.preamble==[1,0,0,1]):
						bit=self.preamble.pop(0)
						print('change signal')
						self.change=1
						break
					else:
						bit=self.preamble.pop(0)
						self.change=0
			if self.change==1:
				self.change=0
				self.signal=[]
				if self.code_index<(len(self.code)-4):
					for i in range(1,5):
						self.signal.append(self.code[self.code_index])
						self.code_index=self.code_index+1
					if len(self.signal)==4:
						if self.signal[0]==0 and self.signal[1]==0:
							self.s_f1=band[0][0]
							self.s_f2=banf[0][1]
						elif self.signal[0]==0 and self.signal[1]==1:
							self.s_f1=band[1][0]
							self.s_f2=band[1][1]
						elif self.signal[0]==1 and self.signal[1]==0:
							self.s_f1=band[2][0]
							self.s_f2=band[2][1]
						else:
							self.s_f1=band[3][0]
							self.s_f2=band[3][1]
						if self.signal[2]==0 and self.signal[3]==0:
							self.r_f1=band[0][0]
							self.r_f2=banf[0][1]
						elif self.signal[2]==0 and self.signal[3]==1:
							self.r_f1=band[1][0]
							self.r_f2=band[1][1]
						elif self.signal[2]==1 and self.signal[3]==0:
							self.r_f1=band[2][0]
							self.r_f2=band[2][1]
						else:
							self.r_f1=band[3][0]
							self.r_f2=band[3][1]

	def loop_transmit(self):
		while True:
			self.transmit()
			time.sleep(24)
			if self.index>=100:
				break
	def loop_t_record(self):
		while True:
			self.t_record()
			time.sleep(0.5)

	def loop_t_decode(self):
		while True:
			self.t_decode()
			time.sleep(0.5)

	def loop_analysis(self):
		while True:
			self.analysis()
			time.sleep(0.5)


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

save_to_file('information_original.txt', information)

mytransmitter=myTransmitter(1,band[1][0],band[1][1],band[2][0],band[2][1],0,1,1,1,[],0,[],[],information,0)
threads=[]
t1=threading.Thread(target=mytransmitter.loop_transmit)
t2=threading.Thread(target=mytransmitter.loop_t_record)
t3=threading.Thread(target=mytransmitter.loop_t_decode)
t4=threading.Thread(target=mytransmitter.loop_analysis)


t2.start()
t1.start()
t3.start()
t4.start()
t1.join()
t2.join()
t3.join()
t4.join()
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

