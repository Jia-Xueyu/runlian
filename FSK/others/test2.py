from tkinter import *  
import time
def on_click():  
    label['text'] = 'no way out' 
    if label['text']=='no way out':
    	time.sleep(3)
    	label['text']='haha'
root = Tk(className='secret file')  
label = Label(root)  
label['text'] = 'be on your own'  
label.pack()  
button = Button(root)  
button['text'] = 'change it'  
button['command'] = on_click  
button.pack()  
root.mainloop()  