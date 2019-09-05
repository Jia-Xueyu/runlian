'''
import pygame,sys
#pygame.init()
#pygame.mixer.init()
#screen=pygame.display.set_mode([640,480])
#pygame.time.delay(1000)
#pygame.mixer.music.load("ACK2021.wav")
#pygame.mixer.music.play()
#soundwav=pygame.mixer.Sound("ACK2021.wav") 
pygame.init()
pygame.mixer.init()
screen=pygame.display.set_mode([640,480])
filename='./information/infor1_1718.wav'
pygame.mixer.music.load(filename)
pygame.mixer.music.play()
#if not pygame.mixer.music.get_busy():
#	soundwav.play()
        #pygame.time.delay(5000)#等待5秒让filename.wav播放结束
'''
import winsound
filename='./information/infor1_1718.wav'
winsound.PlaySound(filename,flags=1)
