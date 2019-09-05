import matlab.engine
eng=matlab.engine.start_matlab()
import threading
import time
from tkinter import *  



class myReceiver(threading.Thread):
	def __init__(self,f1,f2,decode_index,code,code_index,flag,signalnum):
		self.f1=f1
		self.f2=f2
		self.decode_index=decode_index
		self.code=code
		self.code_index=code_index
		self.flag=flag#当flag为5时表示收到超声波信号，信号为11111
		self.signalnum=signalnum

		def on_click():  
			self.label['text'] = 'YOU CAN\'T OPEN IT'

		self.root = Tk(className='secret file')  
		self.label = Label(self.root)  
		self.label['text'] = 'this is a secret file'  
		self.label.pack()  
		self.button = Button(self.root)  
		self.button['text'] = 'open'  
		self.button['command'] = on_click 
		self.button.pack() 
		t1=threading.Thread(target=self.loop_record)
		t2=threading.Thread(target=self.loop_decode)
		t3=threading.Thread(target=self.loop_analysis)
		t2.start()
		t1.start()
		t3.start()
		self.root.mainloop()  

	def r_record(self):
		print('record')
		temp=eng.r_record(self.signalnum)
		self.signalnum=self.signalnum+1

	def r_decode(self):
		print('decode')
		Temp=eng.r_decode(self.decode_index)
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
		#print(self.code)
		print(self.flag)#打印目前flag的值，为5时候表示接收到信号了
		if self.flag==5:
			self.label['text'] ='OPEN SUCCESSFULLY'
			self.label.pack()
		else:
			if self.code_index<(self.decode_index-1)*8:
				if self.code[self.code_index]=='1':#检测到1时flag加1
					self.flag=self.flag+1
					self.code_index=self.code_index+1
				else:
					self.flag=0#如果检测到0,flag为0,重新计算接收到的0的数量
					self.code_index=self.code_index+1

	def loop_record(self):
		while True:
			self.r_record()
			time.sleep(0.5)

	def loop_decode(self):
		while True:
			self.r_decode()
			time.sleep(0.5)
	def loop_analysis(self):
		while True:
			self.analysis()
			time.sleep(0.5)


myreceiver=myReceiver(20000,21000,1,[],0,0,1)
#超声波20khZ~21khZ