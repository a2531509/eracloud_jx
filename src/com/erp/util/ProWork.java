package com.erp.util;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.jdbc.Work;

public abstract class ProWork implements Work{


		private String proSql; //存储过程语句
		
		private List inList;
		
		private List outList;
		
		private List returnList;
		
		@Override
		public abstract void execute(Connection conn) throws SQLException;


		public ProWork(String proSql,List inlist, List outlist){
			this.proSql = proSql;
			this.inList = inlist;
			this.outList = outlist;
		}


		public String getProSql() {
			return proSql;
		}


		public void setProSql(String proSql) {
			this.proSql = proSql;
		}


		public List getInList() {
			return inList;
		}


		public void setInList(List inList) {
			this.inList = inList;
		}


		public List getOutList() {
			return outList;
		}


		public void setOutList(List outList) {
			this.outList = outList;
		}


		public List getReturnList() {
			return returnList;
		}


		public void setReturnList(List returnList) {
			this.returnList = returnList;
		}
		
		
		
}


