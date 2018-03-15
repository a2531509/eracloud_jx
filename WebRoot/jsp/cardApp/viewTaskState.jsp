<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
	<script type="text/javascript">
		var $dgview;
		var $gridview;
		var $girdtest;
		var taskId="";
		$(function(){
		});
		
		 function viewLoad (aa){
			 taskId = aa;
			 createCertType("certType");
				$dgview = $("#dgview");
				$gridview=$dgview.datagrid({
					url:"madeCardTask/madeCardTaskAction!queryPersonMakeCardInfo.action?taskId="+aa,
					pagination:true,
					rownumbers:true,
					border:true,
					striped:true,
					fit:true,
					fitColumns:true,
					//scrollbarSize:0,
					singleSelect:false,
					pageSize:20,
					columns:[[ 
						{field:'TASK_ID',title:'任务编号',sortable:true,width:parseInt($(this).width()*0.1)},
						{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width()*0.1)},
						{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width()*0.1)},
						{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width()*0.15)},
						{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width()*0.15)},
						{field:'APPLY_STATE_NAME',title:'申领状态',sortable:true,width:parseInt($(this).width()*0.1),formatter: function(value,row,index){
							if (row.APPLY_STATE_NAME=="12" || row.APPLY_STATE=="15" ||row.APPLY_STATE=="70"||row.APPLY_STATE=="80"||row.APPLY_STATE=="90"){
								return "<font color=red>"+row.APPLY_STATE_NAME+"<font>";;
							} else {
								return row.APPLY_STATE_NAME;
							}
						}},
						{field:'APPLY_DATE',title:'申领时间',sortable:true,width:parseInt($(this).width()*0.35)}
					]],toolbar:'#tbview',
					onLoadSuccess:function(data){
			            	  $("input[type=checkbox]").each(function(){
			        				this.checked = false;
			        		  });
			            	  if(data.status != 0){
			            		 $.messager.alert('系统消息',data.errMsg,'error');
			            	  }
		            	}
				});
		 }
		 
		 function query(){
			 $dgview.datagrid('load',{
				 	certType:$("#certType").combobox('getValue'),
					certNo:$("#certNo").val(),
					name:$("#name").val()
				});
		 }
		 
	</script>
  <div class="easyui-layout" data-options="fit:true">
	  <div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		  <div id="tbview" style="padding:2px 0">
		        <input name="taskId" id="taskId"  type="hidden"/>
				<table cellpadding="0" cellspacing="0">
					<tr>
						<td style="padding-left:3px;">证件类型：</td>
						<td style="padding-left:3px;"><input type="text" name="certType" id="certType" class="textinput"/></td>
						<td style="padding-left:3px;">证件号码：</td>
						<td style="padding-left:3px;"><input type="text" name="certNo" id="certNo" class="textinput"/></td>
						<td style="padding-left:3px;">姓名：</td>
						<td style="padding-left:3px;"><input type="text" name="name" id="name" class="textinput"/></td>
						<td style="padding-left:3px">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query();">查询</a>
						</td>
					</tr>
				</table>
			</div>
		    <table id="dgview"></table>
	  </div>
  </div>
