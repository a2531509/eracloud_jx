<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $dg;
	$(function() {
		createSysOrg("orgId","branchId","userId");
		createLocalDataSelect("recType",{
					 value:"1",
					 data:[{value:"1",text:"柜面业务"},{value:"2",text:"代理业务"}],
					 onSelect:function(option){
						  if(option.value=="1"){
							  $("#myselforg").css("display","table-row");
					    	  $("#coorg").css("display","none");
						  }else if(option.value=="2"){
							  $("#coorg").css("display","table-row");
					    	  $("#myselforg").css("display","none");
						  }else{
							  $.messager.alert("系统消息","页面加载出错，获取受理点类型出错！","warning");
						  }
					 }
		});
		
		createLocalDataSelect("dealState",{
			 value:"",
			 data:[{value:"",text:"请选择"},{value:"01",text:"待审核"},{value:"02",text:"已审核"},{value:"03",text:"已删除"},{value:"03",text:"已处理"}]
		});

		
		$dg = createDataGrid({
			id:"dg",
			toolbar:"#tb",
			url:"adjustSysAccAction/adjustSysAccAction!queryAdjustInfo.action",
			singleSelect:false,
			pageSize:20,
			frozenColumns:[[
				{field:'ID',checkbox:true},
				{field:"ORG_NAME",title:"处理机构",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"BRCH_NAME",title:"处理网点",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"USER_NAME",title:"处理柜员",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"DEAL_TYPE",title:"处理方式",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"ADJUST_TYPE",title:"调账类型",sortable:true,width:parseInt($(this).width()*0.08)}
			]],
			columns:[[
				{field:"ACPT_ID",title:"受理点编号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"END_ID",title:"终端号/柜员号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"BATCH_NO",title:"批次号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"END_DEAL_NO",title:"终端交易流水号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"CARDIN_DEALNO",title:"卡内交易序号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"DEAL_NO",title:"交易流水号",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"CLR_DATE",title:"清分日期",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"AMT",title:"交易金额",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"BAL_AMT",title:"交易后金额",sortable:true,width:parseInt($(this).width()*0.1)},
	        	{field:"DEAL_DATE",title:"交易时间",sortable:true,width:parseInt($(this).width()*0.1)},
	        	{field:"NOTE",title:"备注",sortable:true}
	        ]]
	   });
	});
	
	//添加调账信息
	function addAdjustAccInfo(){
		$.modalDialog({
			title:"添加调账信息",
			iconCls:"icon-save",
			fit:true,
			maximized:true,
			shadow:false,
			closable:false,
			maximizable:false,
			href:"jsp/cuteDayManage/addadjustaccinfo.jsp",
			buttons:[{
					text:'保存',
					iconCls:'icon-ok',
					handler:function(){
						saveAdjustInfo();
					}
				},{
					text:'取消',
					iconCls:'icon-cancel',
					handler:function() {
						$.modalDialog.handler.dialog('destroy');
					    $.modalDialog.handler = undefined;
					}
				}
		   ]
		});
		
	}
	
	function query(){
		$dg.datagrid("load",{
			queryType:"0",
			"recType":$("#recType").combobox("getValue"),
			"startTime":$("#startTime").val(),
			"endTime":$("#endTime").val(),
			"orgId":$("#orgId").combobox("getValue"),
			"branchId":$("#branchId").combobox("getValue"),
			"userId":$("#userId").combobox("getValue"),
			"coorgId":$("#coorgId").val(),
			"coorgName":$("#coorgName").val(),
			"endId":$("#endId").val(),
			"dealNo":$("#dealNo").val(),
			"dealState":$("#dealState").combobox("getValue")
		});
	}
	
	//调账信息审核 
	function checkAdjustInfo(){
		var checkIds="";
		var rows = $dg.datagird("getChecked");
		if(rows == null || rows.length == 0){
			for(var i=0;i<rows.length;i++){
				checkIds=rows[i].id+"|";
			}
			$.messager.confirm("系统消息","您确定要审核选中的信息吗？",function(r){
				 if(r){
					 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
					 $.post("adjustSysAccAction/adjustSysAccAction!checkAdjustInfo.action","checkIds="+checkIds,function(data,status){
						 $.messager.progress('close');
						 if(status == "success"){
							 $.messager.alert("系统消息",data.errMsg,(data.status == "0" ? "info" : "error"),function(){
								 if(data.status == "0"){
									 $dg.datagrid("reload");
									 $.modalDialog.handler.dialog('destroy');
									 $.modalDialog.handler = undefined;
								 }
							 });
						 }else{
							 $.messager.alert("系统消息","审核信息发生错误，请重新进行操作！","error");
							 return;
						 }
					 },"json");
				 }
			});
		}else{
			$.messager.alert("系统消息","请选择记录信息进行审核！","error");
		}
	}
	
	
	//调账信息删除
	function delAdjustInfo(){
		var checkIds="";
		var rows = $dg.datagird("getChecked");
		if(rows == null || rows.length == 0){
			for(var i=0;i<rows.length;i++){
				checkIds=rows[i].id+"|";
			}
			$.messager.confirm("系统消息","您确定要删除选中的信息吗？",function(r){
				 if(r){
					 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
					 $.post("adjustSysAccAction/adjustSysAccAction!delAdjustInfo.action","checkIds="+checkIds,function(data,status){
						 $.messager.progress('close');
						 if(status == "success"){
							 $.messager.alert("系统消息",data.errMsg,(data.status == "0" ? "info" : "error"),function(){
								 if(data.status == "0"){
									 $dg.datagrid("reload");
									 $.modalDialog.handler.dialog('destroy');
									 $.modalDialog.handler = undefined;
								 }
							 });
						 }else{
							 $.messager.alert("系统消息","删除信息发生错误，请重新进行操作！","error");
							 return;
						 }
					 },"json");
				 }
			});
		}else{
			$.messager.alert("系统消息","请选择记录信息进行删除！","error");
		}
	}
	
	function saveAdjustAccInfo(){
		//确认调账信息
		var row = $dg.datagird("getSelected");
		if(row == null || row.length == 0){
			$.messager.confirm("系统消息","您确定要保存选中的信息吗？",function(r){
				 if(r){
					 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
					 $.post("adjustSysAccAction/saveAdjustAccInfo!delAdjustInfo.action","checkIds="+row.ID,function(data,status){
						 $.messager.progress('close');
						 if(status == "success"){
							 $.messager.alert("系统消息",data.errMsg,(data.status == "0" ? "info" : "error"),function(){
								 if(data.status == "0"){
									 $dg.datagrid("reload");
									 $.modalDialog.handler.dialog('destroy');
									 $.modalDialog.handler = undefined;
								 }
							 });
						 }else{
							 $.messager.alert("系统消息","保存信息发生错误，请重新进行操作！","error");
							 return;
						 }
					 },"json");
				  }
			 });
		}else{
			$.messager.alert("系统消息","请选择记录信息进行处理！","error");
			return;
		}
	}
	
	
	
	function autoCom(){
		if($("#coorgId").val() == ""){
			$("#coorgName").val("");
		}
		$("#coorgId").autocomplete({
			position: {my:"left top",at:"left bottom",of:"#coorgId"},
		    source: function(request,response){
			    $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgId":$("#coorgId").val(),"queryType":"1"},function(data){
			    	response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
			    },'json');
		    },
		    select: function(event,ui){
		      	$('#coorgId').val(ui.item.label);
		        $('#coorgName').val(ui.item.value);
		        return false;
		    },
	      	focus:function(event,ui){
		        return false;
	      	}
	    }); 
	}
	function autoComByName(){
		if($("#coorgName").val() == ""){
			$("#coorgId").val("");
		}
		$("#coorgName").autocomplete({
		    source:function(request,response){
		        $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgName":$("#coorgName").val(),"queryType":"0"},function(data){
		            response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
		        },'json');
		    },
		    select: function(event,ui){
		    	$('#coorgId').val(ui.item.value);
		        $('#coorgName').val(ui.item.label);
		        return false;
		    },
		    focus: function(event,ui){
		        return false;
		    }
	    }); 
	}
	
	
</script>
<n:initpage title="借贷不平调账！<span style='color:red'>注意：</span>针对系统中不平账，进行的反向操作！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="queryAccAdjustInfo">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">受理点类型：</td>
						<td class="tableright"><input name="recType" id="recType" class="textinput"/></td>
						<td class="tableleft">受理起始日期：</td>
						<td class="tableright"><input name="startTime" id="startTime" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false})"/></td>
						<td class="tableleft">受理结束日期：</td>
						<td class="tableright"><input name="endTime" id="endTime" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false})"/></td>
					</tr>
					<tr id="myselforg" >
						<td class="tableleft">办理机构：</td>
						<td class="tableright"><input name="orgId" id="orgId" class="textinput"/></td>
						<td class="tableleft">办理网点：</td>
						<td class="tableright"><input name="branchId" id="branchId" class="textinput"/></td>
						<td class="tableleft">办理柜员：</td>
						<td class="tableright"><input name="userId" id="userId" class="textinput"/></td>
					</tr>
					<tr id="coorg" style="display:none;">
						<td class="tableleft">合作机构编号：</td>
						<td class="tableright"><input name="coorgId" id="coorgId" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft">合作机构名称：</td>
						<td class="tableright"><input name="coorgName" id="coorgName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableleft">受理终端或操作员：</td>
						<td class="tableright"><input name="endId" id="endId" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">业务流水号：</td>
						<td class="tableright"><input name="dealNo"  class="textinput"  id="dealNo" /></td>
						<td class="tableleft">处理状态：</td>
						<td class="tableright" colspan="3"><input name="dealState" type="text" class="textinput" id="dealState"  style="width:174px;"/>
						    <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query();">查询</a>
						    <shiro:hasPermission name="addcrdblist">
						    	<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-adds'" href="javascript:void(0);" class="easyui-linkbutton" onclick="addAdjustAccInfo()">添加调账信息</a>
						    </shiro:hasPermission>
						    <shiro:hasPermission name="checkadddbcrlist">
						    	<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-checkInfo'" href="javascript:void(0);" class="easyui-linkbutton" onclick="checkAdjustAccInfo()">调账信息审核</a>
						    </shiro:hasPermission>
						    <shiro:hasPermission name="delcrdbaddlist">
						    	<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-remove'" href="javascript:void(0);" class="easyui-linkbutton" onclick="delAdjustAccInfo()">删除调账信息</a>
						    </shiro:hasPermission>
						    <shiro:hasPermission name="saveaddcrdblist">
						    	<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveAdjustAccInfo()">调账信息确认</a>
						    </shiro:hasPermission>
							
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="调账信息列表"></table>
	</n:center>
</n:initpage>