import matlab.engine
import threading
import random
import time
eng=matlab.engine.start_matlab()

class myDisturber(threading.Thread):
	def __init__(self,r_f1,r_f2,left,right,sec,record_notation):
		self.r_f1=r_f1
		self.r_f2=r_f2
		self.left=left
		self.right=right
		self.sec=sec
		self.record_notation=record_notation
			

	def notation(self):
		if self.record_notation==0:
			count=(self.right-self.left)/1000
			self.r_f1=random.randint(0, count-1)*1000+self.left
			self.r_f2=self.r_f1+1000
			temp=eng.notation(self.r_f1,self.r_f2)
			if temp==0.0:
				self.record_notation=0
			else:
				self.record_notation=1
			print(self.record_notation,self.r_f1,self.r_f2)
			time.sleep(self.sec)
		else:
			temp=eng.notation(self.r_f1,self.r_f2)
			if temp==0.0:
				self.record_notation=0
			else:
				self.record_notation=1
			print(self.record_notation)



	def disturb(self):
		if self.record_notation==1:
			temp=eng.disturb(self.r_f1,self.r_f2,self.record_notation)


	def loop_disturb(self):
		while True:
			self.disturb()

	def loop_notation(self):
		while True:
			self.notation()





mydisturber=myDisturber(20000,21000,15000,21000,1,0)
t1=threading.Thread(target=mydisturber.loop_notation)
t2=threading.Thread(target=mydisturber.loop_disturb)


t2.start()
t1.start()

t1.join()
t2.join()
