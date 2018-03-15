<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:700}
</style>
<script type="text/javascript">
var $dgview;
var $tempview;
var $gridview;
var checkId;
$(function(){
	//结算状态
	$("#state").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
		value:"",
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"共同存在"},{codeValue:'1',codeName:"运营机构多出"},{codeValue:'2',codeName:"合作机构多出"},{codeValue:'3',codeName:"合作机构多出（运营机构灰记录）"}]
	});
	
	$("#operState").combobox({
		valueField:'codeValue',
		editable:false,
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'',codeName:"请选择"},{codeValue:'1',codeName:"已处理"},{codeValue:'0',codeName:"未处理"}]
	});
	
	$dgview = $("#dgview");
	$gridview=$dgview.datagrid({
		url:"corpCheckAccount/corpCheckAccountAction!findAllCheckBillList.action",
		pagination:true,
		rownumbers:true,
		border:false,
		striped:true,
		fit:true,
		singleSelect:true,
		pageList:[50, 100, 200, 500, 1000],
		frozenColumns:[[
			{field:'ID',checkbox:true},
			{field:'FILEID',title:'对账文件编号',sortable:true,width:parseInt($(this).width()*0.08)},
			{field:'CO_ORG_ID',title:'合作机构编号',sortable:true,width:parseInt($(this).width()*0.1)},
			{field:'CO_ORG_NAME',title:'合作机构名称',sortable:true,width:parseInt($(this).width()*0.1)},
			{field:'DEAL_CODE_NAME',title:'交易类型',sortable:true,width:parseInt($(this).width()*0.1)},
			{field:'STATE',title:'对账状态',sortable:true,width:parseInt($(this).width()*0.15), formatter:function(v){
				if(v == 0){
					return "共同存在";
				} else if (v == 1){
					return "<span style='color:blue'>运营机构多出</span>";
				} else if (v == 2){
					return "<span style='color:green'>合作机构多出</span>";
				} else if (v == 3){
					return "<span style='color:green'>合作机构多出（运营机构灰记录）</span>";
				} else if (v == 4){
					return "<span style='color:blue'>运营机构多出（运营机构灰记录）</span>";
				} else {
					return "<span style='color:red'>未知</span>";
				}
			}}
		]],
		columns:[[
			{field:'END_ID',title:'终端号/网点号',sortable:true},
			{field:'DEAL_BATCH_NO',title:'终端批次号',sortable:true},
			{field:'END_DEAL_NO',title:'终端流水号',sortable:true},
			{field:'DEAL_DATE',title:'交易时间',sortable:true},
			{field:'BANK_ID',title:'银行编号',sortable:true},
			{field:'BANK_ACC',title:'银行账号',sortable:true},
			{field:'CARD_NO',title:'转入卡号',sortable:true},
			{field:'ACC_KIND_NAME',title:'账入账户',sortable:true},
			{field:'CARD_NO2',title:'转出卡号',sortable:true},
			{field:'ACC_KIND2_NAME',title:'转出账户',sortable:true},
			{field:'AMTBEF',title:'转入账户交易前金额',sortable:true, formatter:function(v){
				if(!v || isNaN(v)){
					return;
				}
				return $.foramtMoney(Number(v).div100());
			}},
			{field:'AMT',title:'金额',align:'center',sortable:true, formatter:function(v){
				return $.foramtMoney(Number(v).div100());
			}},
			{field:'OLD_ACTION_NO',title:'业务流水号',sortable:true},
			{field:'OPER_STATE',title:'处理状态',sortable:true},
			{field:'OPER_TYPE',title:'处理类型',sortable:true},
			{field:'USER_ID',title:'处理柜员',sortable:true}
		]],toolbar:'#tbview',
		onLoadSuccess:function(data){
			  $("#dgview").datagrid("resize");
        	  $("input[type=checkbox]").each(function(){
    				this.checked = false;
    		  });
        	  if(data.status != 0){
        		 $.messager.alert('系统消息',data.errMsg,'error');
        	  }
        }
	});
	
});

function autoCom(){
	if($("#coOrgId2").val() == ""){
		$("#coOrgName2").val("");
	}
	$("#coOrgId2").autocomplete({
		position: {my:"left top",at:"left bottom",of:"#coOrgId2"},
	    source: function(request,response){
		    $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgId":$("#coOrgId2").val(),"queryType":"1","initCorpType":"2"},function(data){
		    	response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
		    },'json');
	    },
	    select: function(event,ui){
	      	$('#coOrgId2').val(ui.item.label);
	        $('#coOrgName2').val(ui.item.value);
	        return false;
	    },
      	focus:function(event,ui){
	        return false;
      	}
    }); 
}
function autoComByName(){
	if($("#coOrgName2").val() == ""){
		$("#coOrgId2").val("");
	}
	$("#coOrgName2").autocomplete({
	    source:function(request,response){
	        $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgName":$("#coOrgName2").val(),"queryType":"0","initCorpType":"2"},function(data){
	            response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
	        },'json');
	    },
	    select: function(event,ui){
	    	$('#coOrgId2').val(ui.item.value);
	        $('#coOrgName2').val(ui.item.label);
	        return false;
	    },
	    focus: function(event,ui){
	        return false;
	    }
    }); 
}
$(document).keydown(function (event){ 
	if(event.keyCode == 112){
		basePersonalinfoquery();
		event.preventDefault(); 
	}else if(event.keyCode == 115){
		addOrEditBasePersonal("1");
		event.preventDefault(); 
	}else{
		return true;
	}
});

//预览明细方法
function viewcheckbillList(checkSignId){
	checkId = checkSignId;
	$dgview.datagrid("load",{
		queryType:"0",
		checkSignId:checkSignId,
		"signList.coOrgId":$("#coOrgId2").val(),
		"signList.endId":$("#endId").val(),
		"signList.dealBatchNo":$("#dealBatchNo").val(),
		"signList.endDealNo":$("#endDealNo").val(),
		"signList.cardNo2":$("#cardNo2").val(),
		"signList.state":$("#state").combobox("getValue")
	});
}

//查询页面方法
function queryCheckList(){
	$dgview.datagrid("load",{
		queryType:"0",
		checkSignId:checkId,
		"signList.coOrgId":$("#coOrgId2").val(),
		"signList.endId":$("#endId").val(),
		"signList.dealBatchNo":$("#dealBatchNo").val(),
		"signList.endDealNo":$("#endDealNo").val(),
		"signList.cardNo":$("#cardNo").val(),
		"signList.state":$("#state").combobox("getValue"),
		"signList.operState":$("#operState").combobox("getValue")
	});
}

//合作机构补交易
function dealdzcorepair(){
	var row = $dgview.datagrid('getSelected');
	if(row){
		$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
		$.ajax({   
	        async:true,   
	        cache:false,   
	        timeout:30000,   
	        type:"POST",  
	        dataType:"json",
	        url:"corpCheckAccount/corpCheckAccountAction!dealdzcorepair.action",   
	        data:{checkListId:row.ID},   
	        error:function(jqXHR, textStatus, errorThrown){   
	            if(textStatus=="timeout"){
	            	$.messager.progress('close');
	            	$.messager.alert("系统错误","系统处理超时，请重试！","error", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }else{
	            	$.messager.progress('close');
	                $.messager.alert("系统错误",textStatus,"error", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }  
	        },   
	        success:function(data){
	        	$.messager.progress('close');
	            if(data.status == '0'){
	            	$.messager.alert("提示信息","合作机构补交易平账成功","info", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }else{
	            	$.messager.alert("系统错误",data.errMsg,"error");
	            } 
	        }   
	   });
	}else{
		$.messager.alert("系统消息","请选择一条记录信息进行平账！","error");
	}
}
//运营机构撤销
function dealdzorgcancel(){
	var row = $dgview.datagrid('getSelected');
	if(row){
		$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
		$.ajax({   
	        async:true,   
	        cache:false,   
	        timeout:30000,   
	        type:"POST",  
	        dataType:"json",
	        url:"corpCheckAccount/corpCheckAccountAction!dealdzorgcancel.action",   
	        data:{checkListId:row.ID},   
	        error:function(jqXHR, textStatus, errorThrown){   
	            if(textStatus=="timeout"){
	            	$.messager.progress('close');
	            	$.messager.alert("系统错误","系统处理超时，请重试！","error", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }else{
	            	$.messager.progress('close');
	                $.messager.alert("系统错误",textStatus,"error", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }  
	        },   
	        success:function(data){
	        	$.messager.progress('close');
	            if(data.status == '0'){
	            	$.messager.alert("提示信息","运营机构撤销平账成功","info", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }else{
	            	$.messager.alert("系统错误",data.errMsg,"error");
	            } 
	        }   
	   });
	}else{
		$.messager.alert("系统消息","请选择一条记录信息进行平账！","error");
	}
}
//运营机构补交易
function dealdzorgadd(){
	var row = $dgview.datagrid('getSelected');
	if(row){
		$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
		$.ajax({   
	        async:true,   
	        cache:false,   
	        timeout:30000,   
	        type:"POST",  
	        dataType:"json",
	        url:"corpCheckAccount/corpCheckAccountAction!dealdzorgadd.action",   
	        data:{checkListId:row.ID},   
	        error:function(jqXHR, textStatus, errorThrown){   
	            if(textStatus=="timeout"){
	            	$.messager.progress('close');
	            	$.messager.alert("系统错误","系统处理超时，请重试！","error", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }else{
	            	$.messager.progress('close');
	                $.messager.alert("系统错误",textStatus,"error", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }  
	        },   
	        success:function(data){
	        	$.messager.progress('close');
	            if(data.status == '0'){
	            	$.messager.alert("提示信息","运营机构补交易平账成功","info", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }else{
	            	$.messager.alert("系统错误",data.errMsg,"error");
	            } 
	        }   
	   });
	}else{
		$.messager.alert("系统消息","请选择一条记录信息进行平账！","error");
	}
}
//合作机构记录删除
function dealdzdeletemx(){
	var row = $dgview.datagrid('getSelected');
	if(row){
		$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
		$.ajax({ 
	        timeout:30000,   
	        type:"POST",  
	        dataType:"json",
	        url:"corpCheckAccount/corpCheckAccountAction!dealdzdeletemx.action",   
	        data:{checkListId:row.ID},   
	        error:function(jqXHR, textStatus, errorThrown){   
	            if(textStatus=="timeout"){
	            	$.messager.progress('close');
	            	$.messager.alert("系统错误","系统处理超时，请重试！","error", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }else{
	            	$.messager.progress('close');
	                $.messager.alert("系统错误",textStatus,"error", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }  
	        },   
	        success:function(data){
	        	$.messager.progress('close');
	            if(data.status == '0'){
	            	$.messager.alert("提示信息","合作机构记录删除平账成功","info", function(){
	            		$dgview.datagrid("reload");
	            	});
	            }else{
	            	$.messager.alert("系统错误",data.errMsg,"error");
	            } 
	        }   
	   });
	}else{
		$.messager.alert("系统消息","请选择一条记录信息进行平账！","error");
	}
}
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',split:false,border:false" style="height:auto; overflow:hidden;">
		<div id="tbview" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft" style="width:8%">合作机构编号：</td>
					<td class="tableright" style="width:17%"><input type="text" name="signList.coOrgId" id="coOrgId2" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
					<td class="tableleft" style="width:8%">合作机构名称：</td>
					<td class="tableright" style="width:17%"><input type="text" name="coOrgName" id="coOrgName2" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
					<td class="tableleft" style="width:8%">终端号：</td>
					<td class="tableright" style="width:30%"><input type="text" name="signList.endId" id="endId" class="textinput"/></td>
				</tr>
				<tr>
					<td class="tableleft">批次号：</td>
					<td class="tableright"><input type="text" name="signList.dealBatchNo" id="dealBatchNo" class="textinput"/></td>
					<td class="tableleft">终端流水：</td>
					<td class="tableright"><input type="text" name="signList.endDealNo" id="endDealNo"  class="textinput"/></td>
					<td class="tableleft">转入卡号：</td>
					<td class="tableright"><input type="text" name="signList.cardNo" id="cardNo"  class="textinput" /></td>
				</tr>
				<tr>
					<td class="tableleft">数据状态：</td>
					<td class="tableright"><input type="text" name="signList.state" id="state"  class="easyui-combobox" /></td>
					<td class="tableleft">处理状态：</td>
					<td class="tableright"><input type="text" name="signList.operState" id="operState"  class="textinput easyui-combobox" /></td>
				</tr>
				<tr>
					<td class="tableright" colspan="6" style="padding-left: 30px">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="queryCheckList();">查询</a>
						<span style="padding-left:20px">
							<shiro:hasPermission name="dealdzcorepair">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back" plain="false" onclick="dealdzcorepair();">合作机构补交易</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="dealdzorgcancel">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back_02" plain="false" onclick="dealdzorgcancel();">运营机构撤销</a>
							</shiro:hasPermission>
						</span>
						<span style="padding-left:20px">
							<shiro:hasPermission name="dealdzorgadd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="false" onclick="dealdzorgadd();">运营机构补交易</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="dealdzdeletemx">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" plain="false" onclick="dealdzdeletemx();">合作机构撤销</a>
							</shiro:hasPermission>
						</span>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dgview"></table>
  	</div>
</div>
