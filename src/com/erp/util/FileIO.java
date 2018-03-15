package com.erp.util;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.Writer;
import java.util.List;
import java.util.Locale;

public class FileIO {
	
	private FileIO()
    {
    }

    public static void copyFile(String inName, String outName)
        throws FileNotFoundException, IOException
    {
        BufferedInputStream is = new BufferedInputStream(new FileInputStream(inName));
        BufferedOutputStream os = new BufferedOutputStream(new FileOutputStream(outName));
        copyFile(((InputStream) (is)), ((OutputStream) (os)), true);
    }

    public static void copyFile(InputStream is, OutputStream os, boolean close)
        throws IOException
    {
        int b;
        while((b = is.read()) != -1) 
            os.write(b);
        is.close();
        if(close)
            os.close();
    }

    public static void copyFile(Reader is, Writer os, boolean close)
        throws IOException
    {
        int b;
        while((b = is.read()) != -1) 
            os.write(b);
        is.close();
        if(close)
            os.close();
    }

    public static void copyFile(String inName, PrintWriter pw, boolean close)
        throws FileNotFoundException, IOException
    {
        BufferedReader is = new BufferedReader(new FileReader(inName));
        copyFile(((Reader) (is)), ((Writer) (pw)), close);
    }

    public static String readLine(String inName)
        throws FileNotFoundException, IOException
    {
        BufferedReader is = new BufferedReader(new FileReader(inName));
        String line = null;
        line = is.readLine();
        is.close();
        return line;
    }

    public void copyFileBuffered(String inName, String outName)
        throws FileNotFoundException, IOException
    {
        InputStream is = new FileInputStream(inName);
        OutputStream os = new FileOutputStream(outName);
        int count = 0;
        byte b[] = new byte[8192];
        while((count = is.read(b)) != -1) 
            os.write(b, 0, count);
        is.close();
        os.close();
    }

    public static String readerToString(Reader is)
        throws IOException
    {
        StringBuffer sb = new StringBuffer();
        char b[] = new char[8192];
        int n;
        while((n = is.read(b)) > 0) 
            sb.append(b, 0, n);
        return sb.toString();
    }

    public static String inputStreamToString(InputStream is)
        throws IOException
    {
        return readerToString(new InputStreamReader(is));
    }

    public static void stringToFile(String text, String fileName)
        throws IOException
    {
        BufferedWriter os = new BufferedWriter(new FileWriter(fileName));
        os.write(text);
        os.flush();
        os.close();
    }

    public static void stringToFile(String text, String fileName, String encode)
        throws IOException
    {
        PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(new File(fileName)), encode));
        out.println(text);
        out.close();
    }

    public static String fileToString(String fileName, String encode)
        throws IOException
    {
        BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream(new File(fileName)), encode));
        StringBuffer buffer = new StringBuffer();
        for(String line = ""; (line = in.readLine()) != null;)
            buffer.append(line);

        return buffer.toString();
    }

    public static BufferedReader openFile(String fileName)
        throws IOException
    {
        return new BufferedReader(new FileReader(fileName));
    }

    public static byte[] InputStreamToByte(InputStream iStrm)
        throws IOException
    {
        ByteArrayOutputStream bytestream = new ByteArrayOutputStream();
        int ch;
        while((ch = iStrm.read()) != -1) 
            bytestream.write(ch);
        byte imgdata[] = bytestream.toByteArray();
        bytestream.close();
        return imgdata;
    }

    public static InputStream ByteToInputStream(byte b[])
        throws IOException
    {
        InputStream ins = new ByteArrayInputStream(b);
        return ins;
    }

    public static InputStream String2InputStream(String str)
    {
        try
        {
            return ByteToInputStream(str.getBytes());
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        return null;
    }

    public static String inputStream2String(InputStream is)
    {
        BufferedReader in = new BufferedReader(new InputStreamReader(is));
        StringBuffer buffer = new StringBuffer();
        String line = "";
        try
        {
            while((line = in.readLine()) != null) 
                buffer.append(line);
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        return buffer.toString();
    }

    public static void AppendedToTheFile(String filename, String content)
    {
        try
        {
            String operation = System.getProperty("os.name").toUpperCase(Locale.ENGLISH);
            if(operation.indexOf("AIX") != -1)
                content = new String(content.getBytes("GBK"), "ISO8859_1");
            File write = new File("zt_Optimization.log");
            FileWriter fw = new FileWriter(write, true);
            fw.write((new StringBuilder(String.valueOf(content))).append("\r\n").toString());
            fw.close();
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
    }

    public static void AppendedToTheFile(String filename, List list)
    {
        try
        {
            if(list != null)
            {
                String operation = System.getProperty("os.name").toUpperCase(Locale.ENGLISH);
                File write = new File(filename);
                FileWriter fw = new FileWriter(write, true);
                for(int i = 0; i < list.size(); i++)
                {
                    String content = Tools.processNull(list.get(i));
                    if(operation.indexOf("AIX") != -1)
                        content = new String(content.getBytes("GBK"), "ISO8859_1");
                    fw.write((new StringBuilder(String.valueOf(content))).append("\r\n").toString());
                }

                fw.close();
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
    }

    protected static final int BLKSIZ = 8192;

}
