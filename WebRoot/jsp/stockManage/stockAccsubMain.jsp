<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $dg;
	$(function() {
		createCustomSelect({
			id:"stkCode",
			value:"stk_code",
			text:"stk_name || '【' || stk_code || '】'",
			table:"stock_type",where:"stk_code is not null ",
			isShowDefaultOption:true,
			orderby:"stk_code asc",
			from:1,
			to:30
		});
		createSysCode({id:"goodsState",codeType:"GOODS_STATE"});
		createLocalDataSelect("accState",{
			 data:[
			       {value:"",text:"请选择"},
			       {value:"0",text:"正常"},
			       {value:"1",text:"注销"}
			 ]
		});
		createYesNoSelect("isZero");
		createSysBranch("branchId","operatorId");
		$dg = createDataGrid({
			id:"dg",
			toolbar:"#tb",
			url:"stockManage/stockManageAction!toStockAccQueryIndex.action",
			pageSize:20,
			onBeforeLoad:function(param){
				if(typeof(param["queryType"]) == "undefined" || param["queryType"] != 0){
					return false;
				}
			},
			frozenColumns:[[
				{field:"ORG_NAME",title:"所属机构",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"BRCHNAME",title:"所属网点",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"USERNAME",title:"所属柜员",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"STK_CODE",title:"库存代码",sortable:true,width:parseInt($(this).width()*0.05)},
				{field:"STK_NAME",title:"库存种类",sortable:true,width:parseInt($(this).width()*0.08)}
			]],
			columns:[[
				{field:"ACC_NAME",title:"账户名称",sortable:true,width:parseInt($(this).width()*0.16)},
				{field:"ACCSTATE",title:"账户状态",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"GOODSSTATE",title:"物品状态",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"TOTNUM",title:"总数量",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"TOTFACEVAL",title:"总面额",sortable:true,width:parseInt($(this).width()*0.05)},
	        	{field:"AUTHUSERID",title:"开户柜员",sortable:true,width:parseInt($(this).width()*0.06)},
	        	{field:"OPENDATE",title:"开户时间",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"CLSUSERID",title:"注销柜员",sortable:true,width:parseInt($(this).width()*0.06)},
	        	{field:"CLSDATE",title:"注销日期",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"LASTDEALDATE",title:"最后交易时间",sortable:true,width:parseInt($(this).width()*0.12)},
	        	{field:"NOTE",title:"备注",sortable:true}
	        ]]
	   });
	});
	function query(){
		var params = getformdata("stocklistdetails");
		if(params["isNotBlankNum"] == 0){
			//$.messager.alert("系统消息","查询参数不能全部为空！","warning");
			//return;
		}
		params["queryType"] = "0";
		$dg.datagrid("load",params);
	}
	function addRowsOpenDlg(){
		var subtitle = "",subicon = "";
		subtitle = "库存账户开户";subicon = "icon-add";
		$.modalDialog({
			title:subtitle,width:740,height:300,
			iconCls:subicon,maximizable:false,maximized:true,closed:false,
			closable:false,shadow:false,inline:false,fit:false,resizable:false,
			href:"stockManage/stockManageAction!toStockAccAddIndex.action",
			buttons:[ 
		        {text:"保存",iconCls:"icon-ok",handler:function(){saveStockAccOpen($dg);}},
				{text:"取消",iconCls:"icon-cancel",handler:function(){
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
					}
		        }
			]
		});
	}
</script>
<n:initpage title="库存账户进行管理！<span style='color:red'>注意：</span>当且仅当柜员存在库存账户时，才能进行与库存账户有关的操作！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<form id="stocklistdetails">
				<table style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">库存代码：</td>
						<td class="tableright"><input name="stockAcc.id.stkCode" id="stkCode" class="textinput"/></td>
						<td class="tableleft">物品状态：</td>
						<td class="tableright"><input name="stockAcc.id.goodsState" id="goodsState" class="textinput"/></td>
						<td class="tableleft">库存账户状态：</td>
						<td class="tableright"><input name="stockAcc.accState" id="accState" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input name="stockAcc.brchId" type="text" class="textinput  easyui-validatebox" id="branchId"  style="width:174px;"/></td>
						<td class="tableleft">所属柜员：</td>
						<td class="tableright"><input name="stockAcc.id.userId" type="text" class="textinput  easyui-validatebox" id="operatorId"  style="width:174px;"/></td>
						<td class="tableleft">物品数量是否为0：</td>
						<td class="tableright">
							<input name="isZero"  class="textinput" id="isZero" value="" type="text"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-orgOpenAcc'" href="javascript:void(0);" class="easyui-linkbutton" onclick="addRowsOpenDlg()">开户</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="库存账户信息"></table>
	</n:center>
</n:initpage>