<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	$(function(){
		$personDetail = createDataGrid({
			id:"personDetail",
			url:"cardapply/cardApplyAction!viewPersonDetail2.action?selectedId=" + encodeURI(encodeURI(decodeURI("${param.selectedId}"))),
			fit:true,
			border:false,
			pageList:[300,500,800,1000,1200],
			singleSelect:true,
			queryParams:{queryType:"0"},
			fitColumns:true,
			scrollbarSize:0,
			frozenColumns:[[
			    	{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width()*0.08)},
			    	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width()*0.08)},
			    	{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width()*0.06)},
			    	{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.13)},
			    	]],
			columns:[[
			    	{field:"CORP_NAME",title:"单位名称",sortable:true},
			    	{field:"REGION_NAME",title:"所属区域",sortable:true},
			    	{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true},
			    	{field:"COMM_NAME",title:"社区（村）",sortable:true},
			    	{field:"SURE_FLAG",title:"备注",sortable:false, formatter:function(value){
			    		if(value == '1') {
			    			return "<span style='color:green'>可申领</span>";
			    		} else if(value == '2') {
			    			return "<span style='color:red'>人员状态不正常</span>";
			    		} else if(value == '3') {
			    			return "<span style='color:red'>参保信息不存在或参保状态不正常</span>";
			    		} else if(value == '4') {
			    			return "<span style='color:red'>照片不存在或照片状态不正常</span>";
			    		}
			    		return "<span style='color:yellow'>" + value + "</span>";
			    	}}
			    ]],
		 	toolbar:[{
				text:'导出',
				iconCls:'icon-export',
				handler:function(){
					exportDetailInfo();
				}
			}]
		});
	});
	
	function toQueryDetail(){
		var params = getformdata("viewSearchConts");
		$personDetail.datagrid("load", params);
	}
	
	function exportDetailInfo(){
		$.messager.progress({text:"数据处理中..."});
		$('#downloadcsv').attr('src',"cardapply/cardApplyAction!exportNoAppPerson.action?selectedId=" + encodeURI(encodeURI(decodeURI("${param.selectedId}"))));
		startCycle();
	}

	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("exportNoAppPerson",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
</script>
<n:layout>
	<n:center layoutOptions="border:false">
  		<table id="personDetail"></table>
  		<iframe id="downloadcsv" style="display:none"></iframe>
	</n:center>
</n:layout>