package com.erp.model;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.erp.util.FileIO;
import com.erp.util.Tools;

@SuppressWarnings("serial")
public class PersonBean {
	private String client_Id;
	private String reside_Type;
	private String reside_TypeName;
	private String name;
	private String cert_No;
	private String photo;
    private byte[] photob;
    private String twocodePath;
    
	private  List<BasePersonal> personList=new ArrayList<BasePersonal>();
	
    public List<BasePersonal> getPersonList() {
		return personList;
	}
	public void setPersonList(List<BasePersonal> personList) {
		this.personList = personList;
	}
	public InputStream getPhoto() {
    	try {
			return FileIO.ByteToInputStream(getPhotob());
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
    }
    public void setPhoto(File photo) {
    	try {
    		this.photob=FileIO.InputStreamToByte(new FileInputStream(photo));
		} catch (IOException e) {
			e.printStackTrace();
		}
    }

    public byte[] getPhotob() {
		return photob;
	}

	public void setPhotob(byte[] photob) {
		this.photob = photob;
	}
	public String getCert_No() {
		return cert_No;
	}
	public void setCert_No(String cert_No) {
		this.cert_No = cert_No;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getReside_Type() {
		return reside_Type;
	}
	public void setReside_Type(String reside_Type) {
		this.reside_Type = reside_Type;
	}
	
	public String getReside_TypeName() {
		setReside_TypeName(Tools.processNull(getReside_Type()).equals("1")?"外地":"嘉兴");
		return reside_TypeName;
	}
	public void setReside_TypeName(String reside_TypeName) {
		this.reside_TypeName = reside_TypeName;
	}
	public String getClient_Id() {
		return client_Id;
	}
	public void setClient_Id(String client_Id) {
		this.client_Id = client_Id;
	}
	@Override
	public int hashCode() {
		final int PRIME = 31;
		int result = 1;
		result = PRIME * result + ((cert_No == null) ? 0 : cert_No.hashCode());
		result = PRIME * result + ((client_Id == null) ? 0 : client_Id.hashCode());
		result = PRIME * result + ((name == null) ? 0 : name.hashCode());
		result = PRIME * result + ((personList == null) ? 0 : personList.hashCode());
		result = PRIME * result + ((photo == null) ? 0 : photo.hashCode());
		result = PRIME * result + Arrays.hashCode(photob);
		result = PRIME * result + ((reside_Type == null) ? 0 : reside_Type.hashCode());
		result = PRIME * result + ((reside_TypeName == null) ? 0 : reside_TypeName.hashCode());
		return result;
	}
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		final PersonBean other = (PersonBean) obj;
		if (cert_No == null) {
			if (other.cert_No != null)
				return false;
		} else if (!cert_No.equals(other.cert_No))
			return false;
		if (client_Id == null) {
			if (other.client_Id != null)
				return false;
		} else if (!client_Id.equals(other.client_Id))
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		if (personList == null) {
			if (other.personList != null)
				return false;
		} else if (!personList.equals(other.personList))
			return false;
		if (photo == null) {
			if (other.photo != null)
				return false;
		} else if (!photo.equals(other.photo))
			return false;
		if (!Arrays.equals(photob, other.photob))
			return false;
		if (reside_Type == null) {
			if (other.reside_Type != null)
				return false;
		} else if (!reside_Type.equals(other.reside_Type))
			return false;
		if (reside_TypeName == null) {
			if (other.reside_TypeName != null)
				return false;
		} else if (!reside_TypeName.equals(other.reside_TypeName))
			return false;
		return true;
	}
	public String getTwocodePath() {
		return twocodePath;
	}
	public void setTwocodePath(String twocodePath) {
		this.twocodePath = twocodePath;
	}
}
