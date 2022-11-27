# ShapeIt : A Multimodal Fusion Engine
## DESCRIPTION

* The objective behind this project is to design, implement and test a multi-modal fusion engine able to simultaneously manage three types of modalities, namely, speech recognition, gesture recognition and mouse clicking from three different sources. 
The goal being to combine these information into one instruction that would operate on shapes. The pattern aligns with the MIT project's: "Put That Here" [a link](https://www.media.mit.edu/publications/put-that-there-voice-and-gesture-at-the-graphics-interface/)

* ShapeIt application was the outcome of the project. This interface is built upon the combination of 6 different sub-programs able to communicate through the Ivy bus protocol, namely, ppilot5, sra5, 1$Ivy, Board, Wassup and FusionEngine.

## PREREQUISITES
- For an optimal experience, we advice the use of a headphone provided with a microphone. This will reduce tremendously the speech recognition errors as the interaction is very dependant on the recognition confidence.
- The windows positioning and sizing of the programs \textbf{Board}, \textbf{OneDollarIvy} and \textbf{Wassup} were designed based on a screen resolution of $1920 \times 1080$ at 100\% zoom. If the user's screen does not comply with these specifications, a manual rearrangement and resizing of the windows will be required.
- The french version of this application requires a prior installation of "Microsoft Hortense Desktop" for the text to speech conversion.
- This version was programmed using Processing 4.0.1, we do not guarantee compatibility with other versions.

## USER GUIDELINES
- It is advisable not to use the bat file "launcher_shapeIt.bat" as the export of the executables from Processing resulted in a faulty behavior.
- Instead follow the below guidelines:  
    - Execute the bat file "launcher\_speech.bat"; this will launch the sra5 and the ppilot5 (it will open sra5 with "shapeit\_grammar.grxml" grammar and  ppilot5 with "Microsoft Hortense Desktop").
    - Respect the following order of the launch (in order to have a nice display):  
        - Open "Board/Board.pde" and execute the program;
        - open "Wassup/Wassup.pde" and execute the program;
        - open "OneDollarIvy/OneDollarIvy.pde" and execute the program;
        - open "FusionEngine/FusionEngine.pde" and execute the program;
    The order is very important for the display.
    - You might be needing to resize and reposition the windows;
    - in order to use OneDollarIvy, you will need to import the templates by clicking "i" on its window.
    - you need to spell the world "commence" before any action; 
    - all specified actions can be tested (modulo a good speech recognition);
    - enjoy the experience and shape it like you spell it! 
