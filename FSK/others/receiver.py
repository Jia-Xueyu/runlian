import matlab.engine
eng=matlab.engine.start_matlab()
import threading
import time

init_r_f1=18000
init_r_f2=19000
init_s_f1=17000
init_s_f2=18000
validation=[0,1,1,0,1,1,1,0,1,1,1]
band=[[17000,18000],[18000,19000],[19000,20000],[20000,21000]]
flag=0

class myReceiver(threading.Thread):
	def __init__(self,s_f1,s_f2,r_f1,r_f2,validation,infor,signalnum,decode_index,code,code_index,trans,flag,write_index,preamble):
		self.s_f1=s_f1
		self.s_f2=s_f2
		self.r_f1=r_f1
		self.r_f2=r_f2
		self.validation=validation
		self.infor=[]
		self.signalnum=signalnum
		self.decode_index=decode_index
		self.code=code
		self.code_index=code_index
		self.trans=trans
		self.flag=flag
		self.write_index=write_index
		self.preamble=preamble

	def writedown(self):
		#fh = open('information.txt', 'w')
		if self.write_index<len(self.infor):
			fh = open('information.txt', 'a+')
			for i in self.infor[self.write_index:]:
				fh.write(i)
				print('write down')
				self.write_index=self.write_index+1
			fh.close()

	def r_record(self):
		print('t_record')
		temp=eng.r_record(self.signalnum)
		self.signalnum=self.signalnum+1

	def r_decode(self):
		print('t_decode')
		Temp=eng.r_decode(self.decode_index,self.r_f1,self.r_f2)
		if len(Temp)>0:
			temp=Temp[0]
			for i in temp:
				if i==1.0:
					self.code.append('1')
				else:
					self.code.append('0')
			print(self.code)
			self.decode_index=self.decode_index+1

	def analysis(self):
		print('analysis')
		print(self.infor)
		if len(self.code)>0 and self.code_index<(self.decode_index-1)*8:
			for i in self.code[self.code_index:]:
				self.code_index=self.code_index+1
				self.preamble.append(i)
				if len(self.preamble)==3:
					if(self.preamble==['1','0','1']):
						bit=self.preamble.pop(0)
						print('useful transmisson')
						self.trans=1
						break
					else:
						bit=self.preamble.pop(0)
						self.trans=0
			if self.trans==1:
				self.trans=0
				self.validation=[]
				if self.code_index<len(self.code)-21:
					for i in range(21):
						if i%2==0:
							self.validation.append(self.code[self.code_index])
							self.code_index=self.code_index+1
						else:
							self.infor.append(self.code[self.code_index])
							self.code_index=self.code_index+1
				print(self.validation)
				#if self.validation!=['0','1','1','0','1','1','1','0','1','1','1']:
				if len(list(set(self.validation).intersection(set(['0','1','1','0','1','1','1','0','1','1','1']))))/2<=4:
					band=[[17000,18000],[18000,19000],[19000,20000],[20000,21000]]
					if self.flag%2==0:
						temp=eng.r_changeSignal(self.s_f1,self.s_f2,4,1)
						self.flag=self.flag+1
						self.r_f1=band[3][0]
						self.r_f2=band[3][1]
						self.s_f1=band[0][0]
						self.s_f2=band[0][1]
					else:
						temp=eng.r_changeSignal(self.s_f1,self.s_f2,2,3)
						self.flag=self.flag+1
						self.r_f1=band[1][0]
						self.r_f2=band[1][1]
						self.s_f1=band[2][0]
						self.s_f2=band[2][1]
	def loop_record(self):
		while True:
			self.r_record()
			#time.sleep(0.5)

	def loop_decode(self):
		while True:
			self.r_decode()
			#time.sleep(0.5)
	def loop_analysis(self):
		while True:
			self.analysis()
			#time.sleep(0.5)
	def loop_write(self):
		while True:
			self.writedown()
			#time.sleep(0.5)





myreceiver=myReceiver(band[2][0],band[2][1],band[1][0],band[1][1],[],[],1,1,[],0,0,0,0,[])
t1=threading.Thread(target=myreceiver.loop_record)
t2=threading.Thread(target=myreceiver.loop_decode)
t3=threading.Thread(target=myreceiver.loop_analysis)
t4=threading.Thread(target=myreceiver.loop_write)


t2.start()
t1.start()
t3.start()
t4.start()
t1.join()
t2.join()
t3.join()
t4.join()
'''
while True:
	print('reReceive')
	if msvcrt.getch() == b'a':#按a键接收方接收
		myreceiver.receive()
	if msvcrt.getch() == b'p':
		myreceiver.print()
		'''