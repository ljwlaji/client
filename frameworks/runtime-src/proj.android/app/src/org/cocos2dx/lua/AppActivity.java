/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2016 Chukong Technologies Inc.
Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import android.os.Bundle;
import android.util.Log;

import org.cocos2dx.lib.Cocos2dxActivity;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;

import io.sentry.Attachment;
import io.sentry.Sentry;
import io.sentry.SentryEvent;
import io.sentry.android.core.SentryAndroid;
import io.sentry.protocol.Message;

public class AppActivity extends Cocos2dxActivity{
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        sentryInit();
        super.setEnableVirtualButton(false);
        super.onCreate(savedInstanceState);
//        CrashReport.testJavaCrash();
        // Workaround in https://stackoverflow.com/questions/16283079/re-launch-of-activity-on-home-button-but-only-the-first-time/16447508
        if (!isTaskRoot()) {
            // Android launched another instance of the root activity into an existing task
            //  so just quietly finish and go away, dropping the user back into the activity
            //  at the top of the stack (ie: the last state of this task)
            // Don't need to finish it again since it's finished in super.onCreate .
            return;
        }

        // DO OTHER INITIALIZATION BELOW
        
    }

    private String testGetAppLogs()
    {
        String retString = "";
        String path = getFilesDir().getAbsolutePath() + File.separatorChar + "lastLog.txt";
        File logFile = new File(path);
        if (logFile.exists())
        {
            try
            {
                BufferedReader reader = new BufferedReader(new FileReader(logFile));
                String         line   = "";
                StringBuilder  stringBuilder = new StringBuilder();
                String         ls = System.getProperty("line.separator");
                try
                {
                    while((line = reader.readLine()) != null)
                    {
                        if (!line.contains("cocos2d-x debug info"))
                            continue;
                        //Log.d("testGetAppLogs", line);
                        stringBuilder.append(line.substring(55));
                        stringBuilder.append(ls);
                    }
                    retString = stringBuilder.toString().substring(stringBuilder.length() > 8200 ? stringBuilder.length() - 8200 : 0);
                }
                finally
                {
                    reader.close();
                }
            }
            catch(Exception e)
            {
                Log.e("cocos exception 2", e.toString());
            }
        }
        return retString;
    }

    private void resetLogFile()
    {
        try
        {
            String path = getFilesDir().getAbsolutePath() + File.separatorChar + "persentLog.txt";
            File logFile = new File(path);
            if (logFile.exists())
            {
                FileWriter fileWriter = new FileWriter(logFile);
                fileWriter.write("");
                fileWriter.flush();
                fileWriter.close();
            }
            Runtime.getRuntime().exec("logcat -c ");
            Runtime.getRuntime().exec("logcat -f " + path);
        }
        catch(Exception e)
        {
            Log.d("Sentry", "resetLogFile Exception : " + e.toString());
        }
    }

    private void SendCrashLogEvent(final String pEventName)
    {
        Sentry.withScope(scope -> {
            String FilePath = getFilesDir().getAbsolutePath() + File.separatorChar;
            File currLogFile = new File(FilePath + "persentLog.txt");
            if (currLogFile.exists())
            {
                try {
                    File savedFile = new File(FilePath + "lastLog.txt");
                    if (savedFile.exists())
                        savedFile.delete();
                    currLogFile.renameTo(new File(FilePath + "lastLog.txt"));
                    resetLogFile();
                } catch (Exception e) {
                    Log.d("Sentry", "SendCrashLogEvent : " + e.toString());
                }
            }
            Attachment attachment = new Attachment(FilePath + "lastLog.txt");
            scope.addAttachment(attachment);
            Message msg = new Message();
            msg.setMessage("Crash Log : " + pEventName);
            SentryEvent event = new SentryEvent();
            event.setMessage(msg);
            event.setLogger("testLogger");
            Sentry.captureEvent(event);
        });
    }

    private void sentryInit()
    {
        //https://docs.sentry.io/platforms/android/configuration/filtering/
        SentryAndroid.init(this, options -> {
            // Add a callback that will be used before the event is sent to Sentry.
            // With this callback, you can modify the event or, when returning null, also discard the event.
            options.setBeforeSend((event, hint) -> {
                if (!event.isCrashed())
                    return event;
                Log.d("Sentry", "Sentry Sending a crash event : " + event.getEventId().toString());
                Message msg = new Message();
                msg.setMessage(testGetAppLogs());
                event.setMessage(msg);
                SendCrashLogEvent(event.getEventId().toString());
                return event;
            });
            options.setDsn("http://e35446a2c63745b18ccbb035130e335e@128.1.38.110:9000/5");
            options.setDebug(true);
            options.setSessionTrackingIntervalMillis(60000);
            options.setEnableSessionTracking(true);
            options.setMaxAttachmentSize(20 * 1024 * 1024);
        });
        if (!Sentry.isCrashedLastRun())
            resetLogFile();
    }
}
