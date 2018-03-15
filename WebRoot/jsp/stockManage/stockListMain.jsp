<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var  $stockDetails;
	$(function(){
		createCustomSelect({
			id:"stkCode",
			value:"stk_code",
			text:"stk_name || '【' || stk_code || '】'",
			table:"stock_type",where:"stk_code is not null and stk_code_state = '0' ",
			isShowDefaultOption:true,
			orderby:"stk_code asc",
			from:1,
			to:30
		});
		createLocalDataSelect({
			id:"ownType",
		    data:[{value:"",text:"请选择"},{value:"0",text:"柜员"},{value:"1",text:"客户"}],
		    value:'',
		    onSelect:function(option){
		    	if(option){
		    		if(option.value == "0"){
		    			$(".khtype").hide();
		    			$("#readIdCard").hide();
		    			$(".opertype").show();
		    		}else if(option.value == "1"){
		    			$(".opertype").hide();
		    			$(".khtype").show();
		    			$("#readIdCard").show();;
		    		}else{
		    			$(".khtype").hide();
		    			$("#readIdCard").hide();
		    			$(".opertype").show();
		    		}
		    	}
		    }
		});
		createSysCode({
			id:"goodsState",
			codeType:"GOODS_STATE",
			isShowAll:true,
			isShowDefaultOption:true
		});
		createSysBranch({id:"outBrchId",isJudgePermission:false},{id:"outUserId"});
		createSysBranch("inBrchId","inUserId",{isJudgePermission:false},{});
		createSysBranch("brchId","userId");
		$stockDetails = createDataGrid({
			id:"stockDetails",
			url:"stockManage/stockManageAction!toStockListQueryIndex.action",
			pageSize:20,
			frozenColumns:[[
				{field:'STK_CODE',title:'库存代码',sortable:true,width:parseInt($(this).width()*0.05)},
				{field:'STK_NAME',title:'库存种类',sortable:true,width:parseInt($(this).width()*0.05)},
				{field:'GOODS_ID',title:'库存物理编号',sortable:true},
				{field:'GOODS_NO',title:'库存编号',sortable:true,width:parseInt($(this).width()*0.13)},
				{field:'GOODSSTATE',title:'物品状态',sortable:true},
			]],
			columns:[[
				{field:'OWNTYPE',title:'归属类型',sortable:true,width:parseInt($(this).width()*0.05)},
				{field:'BRCHID',title:'所属网点',sortable:true,width:parseInt($(this).width()*0.1)},
				{field:'USERID',title:'所属柜员',sortable:true,width:parseInt($(this).width()*0.08)},
				{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width()*0.07)},
				{field:'CUSTOMER_NAME',title:'客户名称',sortable:true,width:parseInt($(this).width()*0.06)},
				{field:'TASK_ID',title:'所任务编号',sortable:true,width:parseInt($(this).width()*0.11)},
				{field:'INBRCHID',title:'入库网点',sortable:true,width:parseInt($(this).width()*0.1)},
				{field:'INUSERID',title:'入库柜员',sortable:true,width:parseInt($(this).width()*0.08)},
				{field:'INDATE',title:'入库时间',sortable:true,width:parseInt($(this).width()*0.11)},
				{field:'IN_DEAL_NO',title:'入库流水',sortable:true,width:parseInt($(this).width()*0.05)},
				{field:'OUTBRCHID',title:'出库网点',sortable:true,width:parseInt($(this).width()*0.1)},
				{field:'OUTUSERID',title:'出库柜员',sortable:true,width:parseInt($(this).width()*0.08)},
				{field:'OUTDATE',title:'出库时间',sortable:true,width:parseInt($(this).width()*0.11)},
				{field:'OUT_DEAL_NO',title:'出库流水',sortable:true},
				{field:'NOTE',title:'备注',sortable:false}
			]]
		 });
	});
	function query(){
		var params = getformdata("stocklistdetails");
		if(params["isNotBlankNum"] == 0){
			$.messager.alert("系统消息","查询参数不能全部为空！","warning");
			return;
		}
		params["queryType"] = "0";
		params["stock.customerName"] = $("#customerName").val();
		$stockDetails.datagrid('load',params);
	}
	function readIdCard(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#customerId").val(certinfo["cert_No"]);
		$("#customerName").val(certinfo["name"]);
		query();
	}	
	function readCard(){
		$.messager.progress({text:'正在获取卡信息，请稍后....'});
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0){
			$.messager.progress('close');
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
			return;
		}
		$.messager.progress('close');
		$('#goodsNo').val(cardmsg["card_No"]);
		query();
	}
</script>
<n:initpage title="库房明细进行查询操作!">
	<n:center>
	  	<div id="tb" style="padding:2px 0">
	  		<form id="stocklistdetails">
				<table style="width:100%" class="tablegrid">
					<tr id="dwapply">
						<th class="tableleft">库存代码：</th>
						<td class="tableright"><input name="stock.id.stkCode" id="stkCode" class="textinput"/></td>
						<th class="tableleft">所属任务编号：</th>
						<td class="tableright"><input name="stock.taskId" id="taskId" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入所属制卡任务编号',invalidMessage:'请输入所属制卡任务编号'"/></td>
						<th class="tableleft">物品编号（卡号）：</th>
						<td class="tableright"><input name="stock.goodsNo" id="goodsNo" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入库存物品辅助编号（卡片卡号，设备号，支票和凭证为空）',invalidMessage:'请输入库存物品辅助编号（卡片卡号，设备号，支票和凭证为空）'"/></td>
						<!-- <th class="tableleft">所属批次号：</th>
						<td class="tableright"><input name="stock.batchId" id="batchId" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入所属制卡批次号',invalidMessage:'请输入所属制卡批次号'"/></td> -->
						<th class="tableleft">物品状态：</th>
						<td class="tableright"><input name="stock.id.goodsState" id="goodsState" class="textinput"/></td>
					</tr>
					<tr>
						<th class="tableleft">入库网点：</th>
						<td class="tableright"><input name="stock.inBrchId" id="inBrchId" class="textinput"/></td>
						<th class="tableleft">入库柜员：</th>
						<td class="tableright"><input name="stock.inUserId" id="inUserId" class="textinput"/></td>
						<th class="tableleft">入库起始日期：</th>
						<td class="tableright"><input name="inBeginTime" id="inBeginTime" class="Wdate textinput easyui-validatebox" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" data-options="required:true,missingMessage:'请选择入库起始日期',invalidMessage:'请选择入库起始日期'"/></td>
						<th class="tableleft">入库截止日期：</th>
						<td class="tableright"><input name="inEndTime" id="inEndTime" class="Wdate textinput easyui-validatebox" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" data-options="required:true,missingMessage:'请选择入库截止日期',invalidMessage:'请选择入库截止日期'"/></td>
					</tr>
					<tr>
						<th class="tableleft">出库网点：</th>
						<td class="tableright"><input name="stock.outBrchId" id="outBrchId" class="textinput"/></td>
						<th class="tableleft">出库柜员：</th>
						<td class="tableright"><input name="stock.outUserId" id="outUserId" class="textinput"/></td>
						<th class="tableleft">出库起始日期：</th>
						<td class="tableright"><input name="outBeginTime" id="outBeginTime" class="Wdate textinput easyui-validatebox" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" data-options="required:true,missingMessage:'请选择出库起始日期',invalidMessage:'请选择出库起始日期'"/></td>
						<th class="tableleft">出库截止日期：</th>
						<td class="tableright"><input name="outEndTime" id="outEndTime" class="Wdate textinput easyui-validatebox" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})" data-options="required:true,missingMessage:'请选择出库截止日期',invalidMessage:'请选择出库截止日期'"/></td>
					</tr>
					<tr>
						<th class="tableleft">归属类型：</th>
						<td class="tableright"><input name="stock.ownType" id="ownType" class="textinput"/></td>
						<th class="tableleft  opertype">归属网点：</th>
						<td class="tableright opertype"><input name="stock.brchId" id="brchId" class="textinput"/></td>
						<th class="tableleft  opertype">归属柜员：</th>
						<td class="tableright opertype"><input name="stock.userId" id="userId" class="textinput"/></td>
						<th class="tableleft  khtype"  style="display:none">证件号码：</th>
						<td class="tableright khtype" style="display:none"><input name="stock.customerId" id="customerId" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入证件号码',invalidMessage:'请输入证件号码'"/></td>
						<th class="tableleft  khtype"  style="display:none">客户姓名：</th>
						<td class="tableright khtype" style="display:none"><input name="stock.customerName" id="customerName" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入客户姓名',invalidMessage:'请输入客户姓名'"/></td>
						<td colspan="2" style="text-align:center;">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a style="text-align:center;margin:0 auto;display:none;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()" id="readIdCard">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0)" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="stockDetails" title="查询条件"></table>
	</n:center>
</n:initpage>