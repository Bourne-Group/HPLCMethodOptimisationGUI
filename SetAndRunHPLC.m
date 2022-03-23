function SetAndRunHPLC
    import java.awt.Robot;
    import java.awt.event.*;
    
    clipboard('copy', 'macro "C:\Users\eng_adm\Desktop\Tom\Macro code\Tomv4\FullRun.MAC"');
    
    
    mouse = Robot;
    mouse.mouseMove(1200,1000);
    
    mouse.mousePress(InputEvent.BUTTON1_MASK);
    pause(0.2)
    mouse.mouseRelease(InputEvent.BUTTON1_MASK);
    pause(1)
    mouse.mousePress(InputEvent.BUTTON1_MASK);
    pause(0.2)
    mouse.mouseRelease(InputEvent.BUTTON1_MASK);
    pause(1)
    mouse.keyPress(java.awt.event.KeyEvent.VK_CONTROL)
    pause(0.2)
    mouse.keyPress(java.awt.event.KeyEvent.VK_V)
    pause(0.2)
    mouse.keyRelease(java.awt.event.KeyEvent.VK_V)
    pause(0.2)
    mouse.keyRelease(java.awt.event.KeyEvent.VK_CONTROL)
    pause(1)
    mouse.keyPress(java.awt.event.KeyEvent.VK_ENTER)

end