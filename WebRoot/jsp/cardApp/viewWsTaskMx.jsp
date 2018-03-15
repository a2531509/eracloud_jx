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
					url:"madeCardTask/madeCardTaskAction!queryCardTaskList.action?taskId="+aa,
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
						{field:'DATA_SEQ',checkbox:true},
						{field:'TASK_ID',title:'任务编号',sortable:true,width:parseInt($(this).width()*0.016)},
						{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width()*0.01)},
						{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width()*0.015)},
						{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width()*0.03)},
						{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width()*0.015)},
						{field:'GENDERS',title:'性别',sortable:true,width:parseInt($(this).width()*0.01)},
						{field:'RESIDE_ADDR',title:'地址',sortable:true,width:parseInt($(this).width()*0.01)}
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
					certNo:$("#certNo").val(),
					name:$("#name").val()
				});
		 }
		 
		 function deleteMx(){
			 var rows = $dgview.datagrid('getChecked');
			 var dataSeqs="";
			 if(rows.length > 0){
				 //组转勾选的参数
				 for(var i=0;i<rows.length;i++){
					 dataSeqs = dataSeqs+rows[i].DATA_SEQ+"|";
				 }
				 $.messager.confirm('系统消息','你确定删除吗？', function(r){
		     			if (r){
		     				 $.post("madeCardTask/madeCardTaskAction!deleteTaskMx.action", {dataSeqs:dataSeqs,taskId:rows[0].TASK_ID},
		     						   function(data){
		     						     	if(data.status == '0'){
		     						     		$dgview.datagrid('reload');
		     						     		$.messager.alert('系统消息','删除成功','info');
		     						     	}else{
		     						     		$.messager.alert('系统消息',data.errMsg,'error');
		     						     	}
		     						   }, "json");
		     			}
		     		});
			 }else{
				 $.messager.alert('系统消息','请选择记录进行删除','info');
			 }
		 }
		 
		 //
		 function toAdd(){
			var f;
			//parent.odefaultwindow('选择人员','/jsp/cardApp/taskMxAddView.jsp',function(){});
			parent.$.modalDialog({
				title:'人员信息预览',
				iconCls:'icon-viewInfo',
				width : 800,
				height : 600,
				closable:false,
				//maximizable:true,
				href:"/jsp/cardApp/taskMxAddView.jsp",
				onLoad:function(){
					f = parent.$.modalDialog.handler.find("#dgcc");
					f.datagrid({
						url : "/madeCardTask/madeCardTaskAction!findNoInsertPerson.action?taskId="+taskId,
						width : $(this).width() - 0.1,
						height : $(this).height() - 45,
						pagination:true,
						rownumbers:true,
						border:true,
						fit:true,
						singleSelect:false,
						checkOnSelect:true,
						striped:true,
						autoRowHeight:true,
						showFooter: true,
						columns : [[ 	
					              	{field:'PERSON_ID',checkbox:true},
									{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width : parseInt($(this).width() * 0.3)},
									{field:'CERT_NO',title:'证件类型',sortable:true,width : parseInt($(this).width() * 0.3)},
									{field:'NAME',title:'姓名',sortable:true,width : parseInt($(this).width() * 0.3)}
						           ]],
					              onLoadSuccess:function(data){
					            	  if(data.status != 0){
					            		 $.messager.alert('系统消息',data.errMsg,'error');
					            	  }
					              }
					 });
				},
				buttons:[{
							text : '保存',
							iconCls : 'icon-ok',
							handler : function() {
								//parent.$.modalDialog.openner= $girdtest;//因为添加成功之后，需要刷新这个treegrid，所以先预定义好
								parent.saveSelect(f,taskId,$gridview);
							}
						},{
							text:'取消',
							iconCls:'icon-cancel',
							handler:function() {
								parent.$.modalDialog.handler.dialog('destroy');
							    parent.$.modalDialog.handler = undefined;
							}
						}
			   		]
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
							<shiro:hasPermission name="addHealthTaskList">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="false" onclick="toAdd();">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="deleteHealthTaskList">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false" onclick="deleteMx();">删除</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
		    <table id="dgview"></table>
	  </div>
  </div>
